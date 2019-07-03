//
//  UNNotification+extensions.swift
//  WakyZzz
//
//  Created by Carl Wainwright on 01/07/2019.
//  Copyright © 2019 Olga Volkova OC. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

extension UNNotification {
    func snoozeNotification(for hours: Int, minutes: Int, seconds: Int, title: String, subtitle: String, body: String, sound: String, volume: Float) {
        let content = UNMutableNotificationContent()
        
        content.title = title
        content.subtitle = subtitle
        content.body = body
        if #available(iOS 12.0, *) {
            content.sound = UNNotificationSound.criticalSoundNamed(UNNotificationSoundName(rawValue: sound), withAudioVolume: volume)
        } else {
            // Fallback on earlier versions
            content.sound = UNNotificationSound.init(named: UNNotificationSoundName(rawValue: sound))
        }
       
        //set image on notification
        guard let imageURL = Bundle.main.url(forResource: "wakyzzzImage", withExtension: "png") else { return }
        let attachment = try! UNNotificationAttachment(identifier: "wakyzzzImage", url: imageURL, options: .none)
        
        content.attachments = [attachment]
        
        let identifier = self.request.identifier
        guard let oldTrigger = self.request.trigger as? UNCalendarNotificationTrigger else {
            debugPrint("Cannot reschedule notification without calendar trigger.")
            return
        }
        
        var components = oldTrigger.dateComponents
        components.hour = (components.hour ?? 0) + hours
        components.minute = (components.minute ?? 0) + minutes
        components.second = (components.second ?? 0) + seconds
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                debugPrint("Rescheduling failed", error.localizedDescription)
            } else {
                debugPrint("rescheduled success")
            }
        }
    }
    
//    let snoozeAction = UNNotificationAction(identifier: "Snooze Again", title: "Snooze Again", options: [])
//    let deleteAction = UNNotificationAction(identifier: "DeleteAction", title: "Delete", options: [.destructive])
//    let category = UNNotificationCategory(identifier: categoryIdentifier,
//                                          actions: [snoozeAction, deleteAction],
//                                          intentIdentifiers: [],
//                                          options: [])
//    
//    notificationCenter.setNotificationCategories([category])
    
}
