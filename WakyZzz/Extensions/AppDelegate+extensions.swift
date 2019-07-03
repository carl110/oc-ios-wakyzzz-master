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
        
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        response.notification.request.content.body

        print ("id is \(response.notification.request.identifier)")

        if response.actionIdentifier == "Text" {
            print ("option to text")
            
            let sms: String = "sms:body=Hello, how are you?."
            let strURL: String = sms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            UIApplication.shared.open(URL.init(string: strURL)!, options: [:], completionHandler: nil)
        }
        
        if response.actionIdentifier == "DeleteAction" {
            print ("Action deleted")

            notificationCenter.removePendingNotificationRequests(withIdentifiers: [response.notification.request.identifier])
            
            notificationCenter.removeDeliveredNotifications(withIdentifiers: [response.notification.request.identifier])
        }
        
        if response.actionIdentifier == "Snooze2" {
            print ("snooze for 2nd time")
            evilAlarm(body: "This is the evil alarm", contentIdentifier: response.notification.request.identifier)
        }
        
//        response.notification.request.
        
        if response.actionIdentifier == "Snooze" {
         print ("Snooze button pressed")
            
            snoozeNotification(for: 30, title: "WakyZzz", subtitle: "FirstSnooze Alert", body: "This is your alarm", sound: "sound.mp3", volume: 0.5, request: response.notification.request)
            
        }
        
        let application = UIApplication.shared
        
        if(application.applicationState == .active){
            print("user tapped the notification bar when the app is in foreground")
            
        }
        
        if(application.applicationState == .inactive)
        {
            print("user tapped the notification bar when the app is in background")
        }
    }
    
    
    func scheduleNotification(weekday: Int?, hour: Int, minute: Int, body: String, contentIdentifier: String) {
        //creating the notification content
        let content = UNMutableNotificationContent()
        let categoryIdentifier = "catagory ID"
        
        //adding title, subtitle, body and badge
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
    }
    
    func snoozeNotification(for seconds: TimeInterval, title: String, subtitle: String, body: String, sound: String, volume: Float, request: UNNotificationRequest) {
        let content = UNMutableNotificationContent()
        let categoryIdentifier = "catagory ID"

        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.categoryIdentifier = categoryIdentifier
        if #available(iOS 12.0, *) {
            content.sound = UNNotificationSound.criticalSoundNamed(UNNotificationSoundName(rawValue: sound), withAudioVolume: volume)
        } else {
            // Fallback on earlier versions
            content.sound = UNNotificationSound.init(named: UNNotificationSoundName(rawValue: sound))
        }

        let identifier = request.identifier
        guard (request.trigger as? UNCalendarNotificationTrigger) != nil else {
            debugPrint("Cannot reschedule notification without calendar trigger.")
            return
        }

//        var components = oldTrigger.dateComponents
//        components.hour = (components.hour ?? 0) + hours
//        components.minute = (components.minute ?? 0) + minutes
//        components.second = (components.second ?? 0) + seconds

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
//        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        

        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        let snoozeAction = UNNotificationAction(identifier: "Snooze2", title: "Snooze", options: [])
        let deleteAction = UNNotificationAction(identifier: "DeleteAction", title: "Delete", options: [.destructive])
        let category = UNNotificationCategory(identifier: categoryIdentifier,
                                              actions: [snoozeAction, deleteAction],
                                              intentIdentifiers: [],
                                              options: [])
        
        notificationCenter.setNotificationCategories([category])
    }
    
    func evilAlarm(body: String, contentIdentifier: String) {
        //creating the notification content
        let content = UNMutableNotificationContent()
        let categoryIdentifier = "catagory ID"
        
        //adding title, subtitle, body and badge
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

        // The time/repeat trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let identifier = contentIdentifier
        
        //getting the notification request
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        let textAction = UNNotificationAction(identifier: "Text", title: "Message a friens asking how they are...", options: [])
        let deleteAction = UNNotificationAction(identifier: "DeleteAction", title: "OK Enough", options: [.destructive])
        let category = UNNotificationCategory(identifier: categoryIdentifier,
                                              actions: [textAction, deleteAction],
                                              intentIdentifiers: [],
                                              options: [])
        
        notificationCenter.setNotificationCategories([category])
    }
}

//extension UNNotification {
//    func snoozeNotification(for hours: Int, minutes: Int, seconds: Int) {
//        let content = UNMutableNotificationContent()
//        
//        content.title = "Another Alert"
//        content.body = "Your message"
//        content.sound = .default
//        
//        let identifier = self.request.identifier
//        guard let oldTrigger = self.request.trigger as? UNCalendarNotificationTrigger else {
//            debugPrint("Cannot reschedule notification without calendar trigger.")
//            return
//        }
//        
//        var components = oldTrigger.dateComponents
//        components.hour = (components.hour ?? 0) + hours
//        components.minute = (components.minute ?? 0) + minutes
//        components.second = (components.second ?? 0) + seconds
//        
//        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
//        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
//        UNUserNotificationCenter.current().add(request) { error in
//            if let error = error {
//                debugPrint("Rescheduling failed", error.localizedDescription)
//            } else {
//                debugPrint("rescheduled success")
//            }
//        }
//    }
//
