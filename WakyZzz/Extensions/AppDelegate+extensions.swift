//
//  AppDelegate+extensions.swift
//  WakyZzz
//
//  Created by Carl Wainwright on 01/07/2019.
//  Copyright © 2019 Olga Volkova OC. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        CoreDataManager.shared.turnOffOneTimeAlarm(id: notification.request.identifier)
        
//        alarmViewController.tableView.reloadData()
        
        
        
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        //first snooze
        if response.actionIdentifier == "Snooze" {
            snoozeButtonPressed(seconds: 60,
                                repeatTrigger: true,
                                title: "WakyZzz",
                                subtitle: "Fisrt Snooze",
                                body: "This is your snooze alert",
                                contentIdentifier: response.notification.request.identifier,
                                sound: "sound.mp3",
                                volume: 0.5,
                                firstActionID: "Snooze2",
                                firstActionTitle: "Snooze Again",
                                secondActionID: "2ID",
                                secondActionTitile: "This si just a test",
                                thirdActionID: nil,
                                thirdActionTitle: nil,
                                deleteActionID: "Delete",
                                deleteActionTitle: "Stop Alarm")
        }
        
        //second snooze
        if response.actionIdentifier == "Snooze2" {
            snoozeButtonPressed(seconds: 5,
                                repeatTrigger: false,
                                title: "WakyZzz",
                                subtitle: "No more snoozing",
                                body: "You now need to complete a task: \n* text a friend \n*Send a family member a kind thought",
                                contentIdentifier: response.notification.request.identifier,
                                sound: "sound.mp3",
                                volume: 1,
                                firstActionID: "TextFriend",
                                firstActionTitle: "Message a friend",
                                secondActionID: "TextFamily",
                                secondActionTitile: "Contact family",
                                thirdActionID: nil,
                                thirdActionTitle: nil,
                                deleteActionID: "Defer",
                                deleteActionTitle: "I promis I will complete it later")
        }

        //open sms to text friend
        if response.actionIdentifier == "TextFriend" {

            //open sms with body filled
            let sms: String = "sms:?&body=Hello, how are you?."
            let strURL: String = sms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            UIApplication.shared.open(URL.init(string: strURL)!, options: [:], completionHandler: nil)
        }
        
        //open sms to text family
        if response.actionIdentifier == "TextFamily" {
            let kindThoughtArray =  ["Be kind, for everyone you meet is fighting a battle you know nothing about.",
                                    "Yes, in the poor man's garden grow Far more than herbs and flowers - Kind thoughts, contentment, peace of mind, And Joy for weary hours.",
                                    "We are formed and molded by our thoughts. Those whose minds are shaped by selfless thoughts give joy when they speak or act.",
                                    "Kindness is the language which the deaf can hear and the blind can see.",
                                    "Just one small positive thought in the morning can change your whole day.",
                                    "Grant me the grace to dissolve my negative thoughts about myself today. I breathe the grace of kindness into my heart. And may the grace of healing flow abundantly to every one in need of help."]
            
            //randomly place a kind thought in sms body
            let sms: String = "sms:?&body=\(kindThoughtArray.randomElement()!)"
            let strURL: String = sms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            UIApplication.shared.open(URL.init(string: strURL)!, options: [:], completionHandler: nil)
        }
        
        if response.actionIdentifier == "Defer" {
            snoozeButtonPressed(seconds: TimeInterval(Int.random(in: 1800...7200)),
                                repeatTrigger: false,
                                title: "WakyZzz",
                                subtitle: "Task Completion",
                                body: "You promissed to complete a task od kindness for snoozing your alarm. Have you completed a task yet",
                                contentIdentifier: response.notification.request.identifier,
                                sound: "sound.mp3",
                                volume: 1,
                                firstActionID: "TaksComplete",
                                firstActionTitle: "Yes, I have completed a task",
                                secondActionID: "TextFriend",
                                secondActionTitile: "Text a friend now...",
                                thirdActionID: "TextFamily",
                                thirdActionTitle: "Text family now...",
                                deleteActionID: "Defer",
                                deleteActionTitle: "No, I promis I will complete it later")
        }
        
        //if delete action remove all notifications with same ID
        if response.actionIdentifier == "DeleteAction" {
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [response.notification.request.identifier])
            notificationCenter.removeDeliveredNotifications(withIdentifiers: [response.notification.request.identifier])
        }

//        let application = UIApplication.shared
//        
//        if(application.applicationState == .active){
//            print("user tapped the notification bar when the app is in foreground")
//            
//        }
//        
//        if(application.applicationState == .inactive)
//        {
//            print("user tapped the notification bar when the app is in background")
//        }
        completionHandler()
    }
    
    //notification set by date from alarm
    func scheduleNotification(weekday: Int?, hour: Int, minute: Int, body: String, contentIdentifier: String) {
        //creating the notification content
        let content = UNMutableNotificationContent()
        let categoryIdentifier = "catagory ID"
        
        //adding title, subtitle, body
        content.title = "WakyZzz Alarm"
        content.subtitle = "This is the alarm you set for"
        content.body = body
        if #available(iOS 12.0, *) {
            content.sound = UNNotificationSound.criticalSoundNamed(UNNotificationSoundName(rawValue: "sound.mp3"), withAudioVolume: 0.0)
        } else {
            // Fallback on earlier versions
            content.sound = UNNotificationSound.init(named: UNNotificationSoundName(rawValue: "sound.mp3"))
        }
        content.categoryIdentifier = categoryIdentifier

        //getting the notification trigger
        // The selected time to notify the user
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        dateComponents.weekday? = (weekday)!
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        // The time/repeat trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let identifier = contentIdentifier
        
        //getting the notification request
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
        let deleteAction = UNNotificationAction(identifier: "DeleteAction", title: "Delete", options: [.destructive])
        let category = UNNotificationCategory(identifier: categoryIdentifier,
                                              actions: [snoozeAction, deleteAction],
                                              intentIdentifiers: [],
                                              options: [])
        
        notificationCenter.setNotificationCategories([category])
//        
//        if weekday == nil {
//            CoreDataManager.shared.turnOffOneTimeAlarm(id: contentIdentifier)
//            print ("alrm switched off")
//        }
        
    }
  
    //timer notification set after snooze action
    func snoozeButtonPressed(seconds: TimeInterval, repeatTrigger: Bool, title: String, subtitle: String, body: String, contentIdentifier: String, sound: String, volume: Float, firstActionID: String, firstActionTitle: String, secondActionID: String?, secondActionTitile: String?, thirdActionID: String?, thirdActionTitle: String?, deleteActionID: String, deleteActionTitle: String) {
        //creating the notification content
        let content = UNMutableNotificationContent()
        let categoryIdentifier = "catagory ID"
        
        //adding title, subtitle, body
        content.title = title
        content.subtitle = subtitle
        content.body = body
        if #available(iOS 12.0, *) {
            content.sound = UNNotificationSound.criticalSoundNamed(UNNotificationSoundName(rawValue: sound), withAudioVolume: volume)
        } else {
            // Fallback on earlier versions
            content.sound = UNNotificationSound.init(named: UNNotificationSoundName(rawValue: sound))
        }
        content.categoryIdentifier = categoryIdentifier
        
        let identifier = contentIdentifier
        // The time/repeat trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: repeatTrigger)
        
        
        
        //getting the notification request
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        var catagoryArray: [UNNotificationAction] = []
        
        let firstAction = UNNotificationAction(identifier: firstActionID, title: firstActionTitle, options: [])
        catagoryArray.append(firstAction)
        if secondActionID != nil {
           let secondAction = UNNotificationAction(identifier: secondActionID!, title: secondActionTitile!, options: [])
            catagoryArray.append(secondAction)
        }
        if thirdActionID != nil {
           let thirdAction = UNNotificationAction(identifier: thirdActionID!, title: thirdActionID!, options: [])
            catagoryArray.append(thirdAction)
        }
        
        let deleteAction = UNNotificationAction(identifier: deleteActionID, title: deleteActionTitle, options: [.destructive])
        catagoryArray.append(deleteAction)
        
        let category = UNNotificationCategory(identifier: categoryIdentifier,
                                              actions: catagoryArray,
                                              intentIdentifiers: [],
                                              options: [])
        
        notificationCenter.setNotificationCategories([category])
    }
    
}

