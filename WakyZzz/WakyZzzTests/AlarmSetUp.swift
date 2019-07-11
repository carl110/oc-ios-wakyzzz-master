
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
    let alarmSingular = Alarm()
    var alarm: Alarm?
    var alarms = [Alarm]()
    let avc = AlarmsViewController()
    let appDelegate = AppDelegate()
    var oneTimeAlarmCharacterCount = 0
    var repeatAlarmCharacterCount = 0
    
    override func setUp() {
        coreDataManager = CoreDataManager.shared
        //remove all saved alarms
        coreDataManager.deleteAllAlarms()
        center.removeAllPendingNotificationRequests()
        coreDataManager.deleteAllAlarms()
    }
    
    func saveAlarm() {
        
        print ("save alarm")
        
        alarmSingular.time = 28800
        alarmSingular.enabled = true
        alarmSingular.repeatDays = [false, false, false, false, false, false, false]
        
        let alarm1: () = coreDataManager.saveAlarm(time: Int32(alarmSingular.time),
                                                   enabled: alarmSingular.enabled,
                                                   sun: alarmSingular.repeatDays[0],
                                                   mon: alarmSingular.repeatDays[1],
                                                   tue: alarmSingular.repeatDays[2],
                                                   wed: alarmSingular.repeatDays[3],
                                                   thu: alarmSingular.repeatDays[4],
                                                   fri: alarmSingular.repeatDays[5],
                                                   sat: alarmSingular.repeatDays[6],
                                                   identifier: alarmSingular.identifier)
        avc.setLocalNotification(alarmSingular)
        
        //check alarm calculated this is a one time alarm
        XCTAssertEqual(alarmSingular.repeating, "One time alarm", "This should show as a one time alarm")
        
        alarmSingular.time = 45000
        alarmSingular.enabled = true
        alarmSingular.repeatDays = [false, true, false, true, false, false, false]
        
        let alarm2: () = coreDataManager.saveAlarm(time: Int32(alarmSingular.time),
                                                   enabled: alarmSingular.enabled,
                                                   sun: alarmSingular.repeatDays[0],
                                                   mon: alarmSingular.repeatDays[1],
                                                   tue: alarmSingular.repeatDays[2],
                                                   wed: alarmSingular.repeatDays[3],
                                                   thu: alarmSingular.repeatDays[4],
                                                   fri: alarmSingular.repeatDays[5],
                                                   sat: alarmSingular.repeatDays[6],
                                                   identifier: alarmSingular.identifier)
        avc.setLocalNotification(alarmSingular)
        
        //check alarm calculated this is not a one time alarm
        XCTAssertNotEqual(alarmSingular.repeating, "One time alarm", "This should be a repeating alarm")
        
        //check alarm exists on CoreData
        XCTAssertNotNil(alarm1)
        
        //check alarm exists on CoreData
        XCTAssertNotNil(alarm2)
        
        loadAlarmsCalculateOneTimeAlarms()
        
        //checks ID is calculated to the right format
        XCTAssertEqual(alarmSingular.identifier, Date().string(format: "MMMddyyyyhhmmss"), "This ID should be in the format Month, day, year, hour, minute, seconds")
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
        
        let expN = expectation(description: "Add Notifications")
        center.getPendingNotificationRequests { (notifications) in
            
            print ("add notification closure")
            
            //check there is a localnotification
            XCTAssertEqual(notifications.count, 3, "There should be 3 local notifications set")
            
            for item in notifications {
                
                if item.identifier.count == 15 {
                    self.oneTimeAlarmCharacterCount += 1
                } else if item.identifier.count == 16 {
                    self.repeatAlarmCharacterCount += 1
                }
            }
            XCTAssertEqual(self.oneTimeAlarmCharacterCount, 1, "There should be 1 one time alarm")
            
            XCTAssertEqual(self.repeatAlarmCharacterCount, 2, "There should be 2 repeat alarms")
            expN.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func disableOneTimeAlarm() {
        print ("disableOneTimeAlarm")
        let expO = expectation(description: "Disable one time alarms")
        for item in alarms {
            appDelegate.disableOneTimeAlarm(id: item.identifier)
        }
        
        //reload notifications
        center.removeAllPendingNotificationRequests()
        loadAlarms()
        avc.setLocalNotification(alarmSingular)
        center.getPendingNotificationRequests { (notifications) in
            
            //check notification contains 1
            XCTAssertEqual(notifications.count, 2, "Notfications should only have removed the one time alarm")
            
            //check only repeating alarm exists
            XCTAssertNotEqual(self.alarmSingular.repeating, "One time alarm", "Remaining alarm should be a repeat alarm")
            expO.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func removeLocalNotification() {
        print ("remove local notification")
        let exp = expectation(description: "Remove local notifications")
        center.removeAllPendingNotificationRequests()
        center.getPendingNotificationRequests { (notifications) in
            
            //check notification is now empty
            XCTAssertEqual(notifications.count, 0)
            exp.fulfill()
        }
        waitForExpectations(timeout: 1)
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
    }
}
