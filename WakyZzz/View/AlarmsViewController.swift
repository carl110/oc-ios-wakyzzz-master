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

class AlarmsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UNUserNotificationCenterDelegate, AlarmCellDelegate, AlarmViewControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var alarms = [Alarm]()
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
    }
    
    func config() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        populateAlarms()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in
            
        })
        
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
        alarms.remove(at: alarms.count)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    func editAlarm(at indexPath: IndexPath) {
        editingIndexPath = indexPath
        presentAlarmViewController(alarm: alarm(at: indexPath))
    }
    
    func addAlarm(_ alarm: Alarm, at indexPath: IndexPath) {
        tableView.beginUpdates()
        alarms.insert(alarm, at: indexPath.row)
        print ("adding alarms \(alarm.time)")
        
        let date = alarm.alarmDate
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: date!)
        let minutes = calendar.component(.minute, from: date!)
        let seconds = calendar.component(.second, from: date!)
        print("hours = \(hour):\(minutes):\(seconds)")
        localNotification(hour: hour, minute: minutes)
//        simpleAddNotification(hour: hour, minute: minutes, identifier: alarm.caption, title: alarm.caption, body: alarm.repeating)
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
        let alarmViewController = popupViewController.viewControllers[0] as! AlarmViewController
        alarmViewController.alarm = alarm
        alarmViewController.delegate = self
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
    public func simpleAddNotification(hour: Int, minute: Int, identifier: String, title: String, body: String) {
        
        // Initialize User Notification Center Object
        let center = UNUserNotificationCenter.current()
        
        // The content of the Notification
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        // Define the custom actions.
        let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION",
                                                title: "Accept",
                                                options: UNNotificationActionOptions(rawValue: 0))
        let declineAction = UNNotificationAction(identifier: "DECLINE_ACTION",
                                                 title: "Decline",
                                                 options: UNNotificationActionOptions(rawValue: 0))
        
        // The selected time to notify the user
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        // The time/repeat trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        print ("triggered")
        
        // Initializing the Notification Request object to add to the Notification Center
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Adding the notification to the center
        center.add(request) { (error) in
            if (error) != nil {
                print(error!.localizedDescription)
            }
        }
    }
    
    func localNotification(hour: Int, minute: Int) {
        //creating the notification content
        let content = UNMutableNotificationContent()
        
        //adding title, subtitle, body and badge
        content.title = "Hey this is Simplified iOS"
        content.subtitle = "iOS Development is fun"
        content.body = "We are learning about iOS Local Notification"
        content.badge = 1
        content.sound = UNNotificationSound.init(named: UNNotificationSoundName(rawValue: "sound.mp3"))
        //getting the notification trigger
        // The selected time to notify the user
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        // The time/repeat trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        //getting the notification request
        let request = UNNotificationRequest(identifier: "SimplifiedIOSNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().delegate = self
        
        //adding the notification to notification center
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        print ("run local notification")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //displaying the ios local notification when app is in foreground
        completionHandler([.alert, .badge, .sound])
    }
}

