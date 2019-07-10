
//  CoreDataTests.swift
//  WakyZzzTests
//
//  Created by Carl Wainwright on 08/07/2019.
//  Copyright © 2019 Olga Volkova OC. All rights reserved.
//

import XCTest
import CoreData
import UserNotifications
@testable import WakyZzz

class AlarmSetUp: XCTestCase {
    
    var coreDataManager: CoreDataManager!
    let center = UNUserNotificationCenter.current()
    let alarm = Alarm()
    let avc = AlarmsViewController()
    let appDelegate = AppDelegate()
    
    override func setUp() {
        coreDataManager = CoreDataManager.shared
        //remove all saved alarms
        coreDataManager.deleteAllAlarms()
        center.removeAllPendingNotificationRequests()
    }
    
    func saveAlarm() {
        
        print ("save alarm")
        
        alarm.time = 28800
        alarm.enabled = true
        alarm.repeatDays = [false, false, false, false, false, false, false]
        
        
        let alarm1: () = coreDataManager.saveAlarm(time: Int32(alarm.time),
                                                   enabled: alarm.enabled,
                                                   sun: alarm.repeatDays[0],
                                                   mon: alarm.repeatDays[1],
                                                   tue: alarm.repeatDays[2],
                                                   wed: alarm.repeatDays[3],
                                                   thu: alarm.repeatDays[4],
                                                   fri: alarm.repeatDays[5],
                                                   sat: alarm.repeatDays[6],
                                                   identifier: alarm.identifier)
        
        //check alarm calculated this is a one time alarm
        XCTAssertEqual(alarm.repeating, "One time alarm")
        
        //check alarm exists on CoreData
        XCTAssertNotNil(alarm1)
        
        //checks ID is calculated to the right format
        XCTAssertEqual(alarm.identifier, Date().string(format: "MMMddyyyyhhmmss"))
    }
    
    func addNotifications() {
        
        print ("add notification")
        
        var notificationID = ""
        avc.setLocalNotification(alarm)
        
        center.getPendingNotificationRequests { (notifications) in
            
            //check there is a localnotification
            XCTAssertNotNil(notifications)
            for item in notifications {
                notificationID = item.identifier
            }
            
            //does notification ID = alarm ID
            XCTAssertEqual(notificationID, self.alarm.identifier)
        }
    }
    
    func removeLocalNotification() {
        
        print ("remove local notification")
        avc.removeAllPendingNotifications(alarmID: alarm.identifier) {_ in }
        
        center.getPendingNotificationRequests { (notifications) in
            
            //check notification is now empty
            XCTAssertEqual(notifications.count, 0)
            
        }
    }
    
    func disableOneTimeAlarm() {
        
        print ("disableOneTimeAlarm")
        appDelegate.disableOneTimeAlarm(id: alarm.identifier)
        
        center.getPendingNotificationRequests { (notifications) in
            
            //check notification is now empty
            XCTAssertEqual(notifications.count, 0)
            
        }
        
    }
    
    func testRunInOrder() {
        saveAlarm()
        addNotifications()
        removeLocalNotification()
        addNotifications()
        disableOneTimeAlarm()
        addNotifications()
        removeAllAlarmData()
    }
    
    func removeAllAlarmData() {
        
        print ("removeAllAlarmData")
        coreDataManager.deleteAllAlarms()
        center.removeAllPendingNotificationRequests()
        XCTAssertEqual(coreDataManager.fetchAlarmData()?.count, 0)
        center.getPendingNotificationRequests { (notifications) in
            XCTAssertEqual(notifications.count, 0)
        }
    }
}
