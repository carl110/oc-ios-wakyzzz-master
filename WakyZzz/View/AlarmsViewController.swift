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
    
    private let settingAlarmViewController = SettingAlarmViewController()
    
    var appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    var alarms = [Alarm]()
    {
        //sort the array by date
        didSet {
            let inputFormatter = DateFormatter()
            inputFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
            inputFormatter.dateFormat = "HH:mm"
            
            alarms = alarms.sorted(by: { (first, second) -> Bool in
                
                inputFormatter.date(from: (first.alarmDate?.string(format: "HH:mm"))!)!.timeIntervalSinceNow <= inputFormatter.date(from: (second.alarmDate?.string(format: "HH:mm"))!)!.timeIntervalSinceNow
            })
            tableView.reloadData()
        }
    }
    
    private var editingIndexPath: IndexPath?
    
    private var alarmSound: AVAudioPlayer?
    private var soundVolume: Float = 1
    @IBAction func addButtonPress(_ sender: Any) {
        presentAlarmViewController(alarm: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        config()
        checkNotifications()
//        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func checkNotifications() { //catch any notification that ran when app was not active and user did not respond
        let center = UNUserNotificationCenter.current()
        center.getDeliveredNotifications { (notifications) in
            DispatchQueue.main.async { [weak self] in
                for item in notifications {
                    self?.appDelegate?.disableOneTimeAlarm(id: item.request.identifier)
                }
                self?.loadAlarms()
            }
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { (notifications) in
            print("Count: \(notifications.count)")
            for item in notifications {
                print(item.identifier)
//                print ("time \(item.content.body)")
//                print ("time \(item.trigger)")
            }
        }
    }
    
    func config() {
        tableView.delegate = self
        tableView.dataSource = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound], completionHandler: {didAllow, error in
        })
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
        removeAllPendingNotificationsFor(alarmID: alarm(at: indexPath)!.identifier)

        //remove from array then table
        alarms.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    func editAlarm(at indexPath: IndexPath) {
        editingIndexPath = indexPath
        presentAlarmViewController(alarm: alarm(at: indexPath))
    }
    
    func addAlarm(_ alarm: Alarm, at indexPath: IndexPath) {
        
        //add alarm to array and table, set local notification
        tableView.beginUpdates()
        alarms.insert(alarm, at: indexPath.row)
        setLocalNotification(alarm)
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
                
                //set local notification and update coredata with switch change
                if enabled == false {
                    print ("enabled == false alarm ID \(alarm.identifier)")
                    
                    removeAllPendingNotificationsFor(alarmID: alarm.identifier)
                    CoreDataManager.shared.updateAlarmEnabled(id: alarm.identifier, enabled: false)
                    
                } else {
                    CoreDataManager.shared.updateAlarmEnabled(id: alarm.identifier, enabled: false)
                    setLocalNotification(alarm)
                }
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
        //if edited alarm
        if editingIndexPath != nil {
            
            //dispatch to make sure new notificationsa are set after old ones removed
            DispatchQueue.main.async {
                  self.setLocalNotification(alarm)
            }
          
            loadAlarms()
        }
        else { //if new alarm add to table
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
    
}

