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

    func disableOneTimeAlarm(id: String) {
        let check = CoreDataManager.shared.fetchAlarmFromID(id: id)
        for i in check! {
            if i.sun && i.mon && i.tue && i.wed && i.thu && i.fri && i.sat == false {
                //update bool for enabled on alarm
                CoreDataManager.shared.turnOffOneTimeAlarm(id: id)
            }
        }
    }
    
    //only runs code if app in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //if app open disable onetime alarm and update table
        disableOneTimeAlarm(id: notification.request.identifier)
        
        //fetch updated alarm data for table
        ((window!.rootViewController as? UINavigationController)?.topViewController as? AlarmsViewController)?.loadAlarms()
        completionHandler([.alert, .sound])
    }
    
    //code only runs if user interacts with notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let state = UIApplication.shared.applicationState
    
        //if app in background disable onetime alarm and update table
        if state == .background {
            disableOneTimeAlarm(id: response.notification.request.identifier)
            //fetch updated alarm data for table
            ((window!.rootViewController as? UINavigationController)?.topViewController as? AlarmsViewController)?.loadAlarms()
        }
        
        //if app inactive disable if onetimealarm
        if state == .inactive {
            disableOneTimeAlarm(id: response.notification.request.identifier)
        }
        
        //first snooze
        if response.actionIdentifier == "Snooze" {
            snoozeButtonPressed(seconds: 60,
                                repeatTrigger: false,
                                title: "WakyZzz",
                                subtitle: "Fisrt Snooze",
                                body: "Alarm set for \(response.notification.request.content.categoryIdentifier)",
                                contentIdentifier: response.notification.request.identifier,
                                sound: "alarmSound3.mp3",
                                volume: 0.8,
                                firstActionID: "Snooze2",
                                firstActionTitle: "Snooze Again",
                                secondActionID: nil,
                                secondActionTitile: nil,
                                thirdActionID: nil,
                                thirdActionTitle: nil,
                                deleteActionID: "Delete",
                                deleteActionTitle: "Stop Alarm",
                                time: response.notification.request.content.categoryIdentifier)
        }
        
        //second snooze
        if response.actionIdentifier == "Snooze2" {
            snoozeButtonPressed(seconds: 60,
                                repeatTrigger: false,
                                title: "WakyZzz",
                                subtitle: "\(response.notification.request.content.categoryIdentifier)",
                                body: "You now need to complete a task: \n* text a friend \n*Send a family member a kind thought",
                                contentIdentifier: response.notification.request.identifier,
                                sound: "scarySound.mp3",
                                volume: 1,
                                firstActionID: "TextFriend",
                                firstActionTitle: "Message a friend",
                                secondActionID: "TextFamily",
                                secondActionTitile: "Contact family",
                                thirdActionID: nil,
                                thirdActionTitle: nil,
                                deleteActionID: "Defer",
                                deleteActionTitle: "I promis I will complete it later",
                                time: response.notification.request.content.categoryIdentifier)
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
                                body: "You promissed to complete a task for snoozing your alarm set for \(response.notification.request.content.categoryIdentifier). Have you completed the task yet?",
                                contentIdentifier: response.notification.request.identifier,
                                sound: "howl.mp3",
                                volume: 1,
                                firstActionID: "TaksComplete",
                                firstActionTitle: "Yes, I have completed a task",
                                secondActionID: "TextFriend",
                                secondActionTitile: "Text a friend now...",
                                thirdActionID: "TextFamily",
                                thirdActionTitle: "Text family now...",
                                deleteActionID: "Defer",
                                deleteActionTitle: "No, I promis I will complete it later",
                                time: response.notification.request.content.categoryIdentifier)
        }
        
        //if delete action remove all notifications with same ID
        if response.actionIdentifier == "DeleteAction" {
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [response.notification.request.identifier])
            notificationCenter.removeDeliveredNotifications(withIdentifiers: [response.notification.request.identifier])
        }
        completionHandler()
    }
    
    //notification set by date from alarm
    func scheduleNotification(weekday: Int, hour: Int, minute: Int, body: String, contentIdentifier: String, time: String) {
        
        //creating the notification content
        let content = UNMutableNotificationContent()
        let categoryIdentifier = time
        content.title = "WakyZzz Alarm"
        content.subtitle = "This is the alarm you set for"
        content.body = body
        if #available(iOS 12.0, *) {
            content.sound = UNNotificationSound.criticalSoundNamed(UNNotificationSoundName(rawValue: "alarmSound2.mp3"), withAudioVolume: 0.4)
        } else {
            // Fallback on earlier versions
            content.sound = UNNotificationSound.init(named: UNNotificationSoundName(rawValue: "alarmSound2.mp3"))
        }
        content.categoryIdentifier = categoryIdentifier
        
        //getting the notification trigger
        // The selected time to notify the user
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        dateComponents.weekday = weekday
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
    }
    
    //timer notification set after snooze action
    func snoozeButtonPressed(seconds: TimeInterval, repeatTrigger: Bool, title: String, subtitle: String, body: String, contentIdentifier: String, sound: String, volume: Float, firstActionID: String, firstActionTitle: String, secondActionID: String?, secondActionTitile: String?, thirdActionID: String?, thirdActionTitle: String?, deleteActionID: String, deleteActionTitle: String, time: String) {
        //creating the notification content
        let content = UNMutableNotificationContent()
        let categoryIdentifier = time
        
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

