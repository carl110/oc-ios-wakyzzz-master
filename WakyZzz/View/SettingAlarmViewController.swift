//
//  AlarmViewController.swift
//  WakyZzz
//
//  Created by Olga Volkova on 2018-05-30.
//  Copyright © 2018 Olga Volkova OC. All rights reserved.
//

import Foundation
import UIKit

protocol AlarmViewControllerDelegate {
    func alarmViewControllerDone(alarm: Alarm)
    func alarmViewControllerCancel()
}

class SettingAlarmViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var alarm: Alarm?
    var delegate: AlarmViewControllerDelegate?
    private let date = Date()
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    
    func config() {        
        if alarm == nil {
            navigationItem.title = "New Alarm"
            alarm = Alarm()
        }
        else {
            navigationItem.title = "Edit Alarm"
        }
        tableView.delegate = self
        tableView.dataSource = self
        
        //if adding new alarm set datepicker time to 08:00
        if alarm?.time == 2880 {
            datePicker.setNewDate(from: "08:00", format: "HH:mm")
        } else { //if alarm exists set time as alarm time
            datePicker.date = (alarm?.alarmDate)!
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Alarm.daysOfWeek.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayOfWeekCell", for: indexPath)
        cell.textLabel?.text = Alarm.daysOfWeek[indexPath.row]
        cell.accessoryType = (alarm?.repeatDays[indexPath.row])! ? .checkmark : .none
        if (alarm?.repeatDays[indexPath.row])! {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Repeat on following weekdays"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        alarm?.repeatDays[indexPath.row] = true
        tableView.cellForRow(at: indexPath)?.accessoryType = (alarm?.repeatDays[indexPath.row])! ? .checkmark : .none
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        alarm?.repeatDays[indexPath.row] = false
        tableView.cellForRow(at: indexPath)?.accessoryType = (alarm?.repeatDays[indexPath.row])! ? .checkmark : .none
    }
    
    @IBAction func cancelButtonPress(_ sender: Any) { //go back to alarm view
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPress(_ sender: Any) {
        let checkAlarms = CoreDataManager.shared.fetchAlarmFromID(id: alarm!.identifier)
        
        //if alarm exists just update alarm
        if (checkAlarms?.count)! > 0 {
            
            //completionhandler to ensure notifications are removed before the next code is run
            removeAllPendingNotifications(alarmID: alarm!.identifier) { (sucess) in
                if sucess {
                    DispatchQueue.main.async {
                        //update changes to alarm
                        CoreDataManager.shared.updateAlarmRepeatDays(id: self.alarm!.identifier, time: self.getTime(date: self.datePicker.date),
                                                                     sun: self.alarm!.repeatDays[0],
                                                                     mon: self.alarm!.repeatDays[1],
                                                                     tue: self.alarm!.repeatDays[2],
                                                                     wed: self.alarm!.repeatDays[3],
                                                                     thu: self.alarm!.repeatDays[4],
                                                                     fri: self.alarm!.repeatDays[5],
                                                                     sat: self.alarm!.repeatDays[6])
                    }
                    self.addAlarmtoPreviouseViewController()
                }
            }
        } else { //if new alarm add.
            CoreDataManager.shared.saveAlarm(time: getTime(date: datePicker.date),
                                             enabled: alarm!.enabled,
                                             sun: alarm!.repeatDays[0],
                                             mon: alarm!.repeatDays[1],
                                             tue: alarm!.repeatDays[2],
                                             wed: alarm!.repeatDays[3],
                                             thu: alarm!.repeatDays[4],
                                             fri: alarm!.repeatDays[5],
                                             sat: alarm!.repeatDays[6],
                                             identifier: alarm!.identifier)
            addAlarmtoPreviouseViewController()
        }
    }
    
    func addAlarmtoPreviouseViewController() {
        DispatchQueue.main.async {
            //add alarm as per date picker time
            self.alarm?.setTime(date: self.datePicker.date)
            self.delegate?.alarmViewControllerDone(alarm: self.alarm!)
            //go back to alarm view
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
