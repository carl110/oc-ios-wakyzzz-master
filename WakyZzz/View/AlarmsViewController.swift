//
//  AlarmsViewController.swift
//  WakyZzz
//
//  Created by Olga Volkova on 2018-05-30.
//  Copyright © 2018 Olga Volkova OC. All rights reserved.
//

import UIKit
import AVFoundation
import UserNotifications
import CoreData

class AlarmsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UNUserNotificationCenterDelegate, AlarmCellDelegate, AlarmViewControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    let settingAlarmViewController = SettingAlarmViewController()
    
    var alarms = [Alarm]()
//    {
//        didSet {
//
//            print ("didset")
//            alarms = alarms.sorted(by: { (first, second) -> Bool in
//
//                let sortByDate = Calendar.current.compare(first.alarmDate ?? Date(), to: second.alarmDate ?? Date(), toGranularity: .minute)
//
//
//
//                switch sortByDate {
//
//                case .orderedDescending:
//                    first < second
//                    return true
//
//                default:
//                    print ("default")
//                    return false
////                case .orderedSame:
////
////                    print ("order 2")
////                    return false
////                case .orderedDescending:
////                    print ("order 3")
////                    return false
//                }
////                return first.time < second.time
//            })
//        }
//    }
    
    
    
    var editingIndexPath: IndexPath?
    
    private var alarmSound: AVAudioPlayer?
    private var soundVolume: Float = 1
    @IBAction func addButtonPress(_ sender: Any) {
        presentAlarmViewController(alarm: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        config()
        loadAlarms()
    }
    
    func config() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
//        populateAlarms()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in
            
        })
        
    }
    
    func loadAlarms() {
        let fetchedData = CoreDataManager.shared.fetchAlarmData()
        
        for i in fetchedData! {
            var alarm: Alarm
            alarm = Alarm()
            
            alarm.time = Int(i.time)
            
            alarm.enabled = i.enabled
            
            alarm.repeatDays = [i.sun, i.mon, i.tue, i.wed, i.thu, i.fri, i.sat]
            
            alarms.append(alarm)
        }
    }
    
    func populateAlarms() {
        
        var alarm: Alarm
        
        // Weekdays 5am
        alarm = Alarm()
        alarm.time = 5 * 3600
        for i in 1 ... 5 {
            alarm.repeatDays[i] = true
        }
        alarms.append(alarm)
        
        // Weekend 9am
        alarm = Alarm()
        alarm.time = 9 * 3600
        alarm.enabled = false
        alarm.repeatDays[0] = true
        alarm.repeatDays[6] = true
        alarms.append(alarm)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell", for: indexPath) as! AlarmTableViewCell
        cell.delegate = self
        if let alarm = alarm(at: indexPath) {
            cell.populate(caption: alarm.caption, subcaption: alarm.repeating, enabled: alarm.enabled)
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.deleteAlarm(at: indexPath)
        }
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            self.editAlarm(at: indexPath)
        }
        return [delete, edit]
    }
    
    func alarm(at indexPath: IndexPath) -> Alarm? {
        return indexPath.row < alarms.count ? alarms[indexPath.row] : nil
    }
    
    func deleteAlarm(at indexPath: IndexPath) {
        tableView.beginUpdates()
        
        //remove from coredata
        CoreDataManager.shared.deleteAlarm(id: alarm(at: indexPath)!.identifier)

        //remove from array then table
        alarms.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        
        
    }
    
    func editAlarm(at indexPath: IndexPath) {
        editingIndexPath = indexPath
        presentAlarmViewController(alarm: alarm(at: indexPath))
        //            self.alarmViewController.datePicker.date = (self.alarm(at: indexPath)?.alarmDate)!

    }
    
    func addAlarm(_ alarm: Alarm, at indexPath: IndexPath) {
        tableView.beginUpdates()
        alarms.insert(alarm, at: indexPath.row)
        
        
        let date = alarm.alarmDate
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date!)
        let minutes = calendar.component(.minute, from: date!)
        
        //set weekday int to sunday for loop
        var weekDay = 1
        
        //if one time alarm do not add day of week
        if alarm.repeating.isEqualToString(find: "One time alarm") {
            localNotification(weekday: nil, hour: hour, minute: minutes, body: alarm.caption)
        } else {
            for weekDayBool in alarm.repeatDays {
                if weekDayBool == true {
                    localNotification(weekday: weekDay, hour: hour, minute: minutes, body: alarm.caption)
                }
                weekDay += 1
            }
        }


        
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    func moveAlarm(from originalIndextPath: IndexPath, to targetIndexPath: IndexPath) {
        let alarm = alarms.remove(at: originalIndextPath.row)
        alarms.insert(alarm, at: targetIndexPath.row)
        tableView.reloadData()
    }
    
    func alarmCell(_ cell: AlarmTableViewCell, enabledChanged enabled: Bool) {
        if let indexPath = tableView.indexPath(for: cell) {
            if let alarm = self.alarm(at: indexPath) {
                alarm.enabled = enabled
            }
        }
    }
    
    func presentAlarmViewController(alarm: Alarm?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let popupViewController = storyboard.instantiateViewController(withIdentifier: "DetailNavigationController") as! UINavigationController
        let settingAlarmViewController = popupViewController.viewControllers[0] as! SettingAlarmViewController
        settingAlarmViewController.alarm = alarm
        settingAlarmViewController.delegate = self
        present(popupViewController, animated: true, completion: nil)
    }
    
    func alarmViewControllerDone(alarm: Alarm) {
        if let editingIndexPath = editingIndexPath {
            tableView.reloadRows(at: [editingIndexPath], with: .automatic)
        }
        else {
            addAlarm(alarm, at: IndexPath(row: alarms.count, section: 0))
        }
        editingIndexPath = nil
    }
    
    func alarmViewControllerCancel() {
        editingIndexPath = nil
        
    }
    
    //first alarm sound
    func playSound() {
        let path = Bundle.main.path(forResource: "sound.mp3", ofType: nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            self.alarmSound = try AVAudioPlayer(contentsOf: url)
            self.alarmSound?.play()
            self.alarmSound?.volume = self.soundVolume
        } catch {
            print ("Unable to locate sound file")
        }
        
    }
    
    func localNotification(weekday: Int?, hour: Int, minute: Int, body: String) {
        //creating the notification content
        let content = UNMutableNotificationContent()
        
        //adding title, subtitle, body and badge
        content.title = "WakyZzz Alarm"
        content.subtitle = "This is the alarm you set for"
        content.body = body
        content.badge = 1
        content.sound = UNNotificationSound.init(named: UNNotificationSoundName(rawValue: "sound.mp3"))
        
        //getting the notification trigger
        // The selected time to notify the user
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        dateComponents.weekday? = (weekday)!
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        // The time/repeat trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        //getting the notification request
        let request = UNNotificationRequest(identifier: "SimplifiedIOSNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().delegate = self
        
        //adding the notification to notification center
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //displaying the ios local notification when app is in foreground
        completionHandler([.alert, .sound])
    }
    
}

