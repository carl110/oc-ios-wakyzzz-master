//
//  UIViewController.swift
//  WakyZzz
//
//  Created by Carl Wainwright on 26/06/2019.
//  Copyright © 2019 Olga Volkova OC. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

extension UIViewController {
    
    //get time in Int 32 format from date
    func getTime(date: Date) -> Int32 {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.hour, .minute, .month, .year, .day, .second, .weekOfMonth], from: date as Date)
        return Int32(components.hour! * 3600 + components.minute! * 60)
    }
    
    func removeAllPendingNotifications(alarmID: String, completion: @escaping (_ success: Bool) -> Void) {
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            //for all notifications that contain the alarm ID -> remove
            for requests in requests {
                if requests.identifier.contains(alarmID) {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [requests.identifier])
                    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [requests.identifier])
                    print ("notification removd is \(requests.identifier)")
                }
            }
            completion(true)
        }
        
    }
    
    
    func removeAllPendingNotificationsForsfagb(alarmID: String) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            //for all notifications that contain the alarm ID -> remove
            for requests in requests {
                if requests.identifier.contains(alarmID) {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [requests.identifier])
                    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [requests.identifier])
                    print ("notification removd is \(requests.identifier)")
                }
            }
        }
    }
    
    func setLocalNotification(_ alarm: Alarm) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        //set date perameters
        let date = alarm.alarmDate
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date!)
        let minutes = calendar.component(.minute, from: date!)
        
        //set weekday int to sunday for loop
        var weekDay = 1
        
        //if one time set day as today
        if alarm.repeating.isEqualToString(find: "One time alarm") {
            appDelegate?.scheduleNotification(weekday: Calendar.current.component(.weekday, from: Date()), hour: hour, minute: minutes, body: alarm.caption, contentIdentifier: alarm.identifier, time: alarm.caption)
            print ("One time alarm - \(hour):\(minutes)")
        } else {
            for weekDayBool in alarm.repeatDays {
                if weekDayBool == true {
                    appDelegate?.scheduleNotification(weekday: weekDay, hour: hour, minute: minutes, body: alarm.caption, contentIdentifier: "\(alarm.identifier)\(weekDay)", time: alarm.caption)
                    print ("repeat alarm \(hour):\(minutes) \(weekDay)")
                }
                weekDay += 1
            }
        }
    } 
}
