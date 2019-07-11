
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
    var alarms = [Alarm]()
    let avc = AlarmsViewController()
    let appDelegate = AppDelegate()
    var oneTimeAlarm = 0
    var repeatAlarm = 0
    
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
        XCTAssertEqual(alarm.repeating, "One time alarm", "This should show as a one time alarm")
        
        alarm.time = 45000
        alarm.enabled = true
        alarm.repeatDays = [false, true, false, true, false, false, false]
        
        let alarm2: () = coreDataManager.saveAlarm(time: Int32(alarm.time),
                                                   enabled: alarm.enabled,
                                                   sun: alarm.repeatDays[0],
                                                   mon: alarm.repeatDays[1],
                                                   tue: alarm.repeatDays[2],
                                                   wed: alarm.repeatDays[3],
                                                   thu: alarm.repeatDays[4],
                                                   fri: alarm.repeatDays[5],
                                                   sat: alarm.repeatDays[6],
                                                   identifier: alarm.identifier)
        
        //check alarm calculated this is not a one time alarm
        XCTAssertNotEqual(alarm.repeating, "One time alarm", "This should be a repeating alarm")
        
        //check alarm exists on CoreData
        XCTAssertNotNil(alarm1)
        
        //check alarm exists on CoreData
        XCTAssertNotNil(alarm2)
        
        loadAlarmsCalculateOneTimeAlarms()

        //checks ID is calculated to the right format
        XCTAssertEqual(alarm.identifier, Date().string(format: "MMMddyyyyhhmmss"), "This ID should be in the format Month, day, year, hour, minute, seconds")
    }
    
    func loadAlarms() {
        //clear array before fetching coredata
        alarms.removeAll()
        let fetchedData = CoreDataManager.shared.fetchAlarmData()
        //run through alarms saved and add to array
        for i in fetchedData! {
            var alarm: Alarm
            alarm = Alarm()
            alarm.time = Int(i.time)
            alarm.enabled = i.enabled
            alarm.repeatDays = [i.sun, i.mon, i.tue, i.wed, i.thu, i.fri, i.sat]
            alarm.identifier = i.identifier
            alarms.append(alarm)
        }
    }
    
    func loadAlarmsCalculateOneTimeAlarms() {
        print ("loadAlarmsCalculateOneTimeAlarms")
        loadAlarms()
        var oneTimeAlarm = 0
        var repeatAlarm = 0
        
        //run through alarm array and check repeating alarms
        for i in alarms {
            if i.repeating.isEqualToString(find: "One time alarm") {
                oneTimeAlarm += 1
            } else {
                repeatAlarm += 1
            }
        }
        
        XCTAssertEqual(oneTimeAlarm, 1, "There should be 1 One time alarm")
        
        XCTAssertEqual(repeatAlarm, 1, "There should be 1 repeating alarm")

    }
    
    func addNotifications() {
        print ("add notification")
        avc.setLocalNotification(alarm)
        center.getPendingNotificationRequests { (notifications) in
            
            //check there is a localnotification
            XCTAssertEqual(notifications.count, 2, "There should be 2 local notifications set")

            for item in notifications {

                //does notification ID = alarm ID
                XCTAssertEqual(item.identifier, self.alarm.identifier, "The alarm ID and the notification ID should be the same")
            }
        }
    }
    
    func disableOneTimeAlarm() {
        print ("disableOneTimeAlarm")
        for item in alarms {
            if item.repeating.isEqualToString(find: "One time alarm") {
                appDelegate.disableOneTimeAlarm(id: item.identifier)
            }
        }
        center.getPendingNotificationRequests { (notifications) in
            
            //check notification contains 1
            XCTAssertEqual(notifications.count, 1, "Notfications should only have removed the one time alarm")
            
            //check only repeating alarm exists
            XCTAssertNotEqual(self.alarm.repeating, "One time alarm", "Remaining alarm should be a repeat alarm")
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

    func testRunInOrder() {
        saveAlarm()
        addNotifications()
        disableOneTimeAlarm()
        removeLocalNotification()
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
