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
    private let date = Date()
    
    var delegate: AlarmViewControllerDelegate?

    
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
        
        //if adding new alarm set datepicker time to 08:00 or to the alarm time
        if alarm?.time == 2880 {
            datePicker.setNewDate(from: "08:00", format: "HH:mm")
        } else {

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
    
    @IBAction func cancelButtonPress(_ sender: Any) {
        //go back to alarm view
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPress(_ sender: Any) {

        let checkAlarms = CoreDataManager.shared.fetchAlarmFromID(id: alarm!.identifier)

        //if alarm exists just update alarm
        if (checkAlarms?.count)! > 0 {
            //update changes to alarm
            CoreDataManager.shared.updateAlarmRepeatDays(id: alarm!.identifier, time: getTime(date: datePicker.date), sun: alarm!.repeatDays[0], mon: alarm!.repeatDays[1], tue: alarm!.repeatDays[2], wed: alarm!.repeatDays[3], thu: alarm!.repeatDays[4], fri: alarm!.repeatDays[5], sat: alarm!.repeatDays[6])
        } else {
            CoreDataManager.shared.saveAlarm(time: getTime(date: datePicker.date), enabled: alarm!.enabled, sun: alarm!.repeatDays[0], mon: alarm!.repeatDays[1], tue: alarm!.repeatDays[2], wed: alarm!.repeatDays[3], thu: alarm!.repeatDays[4], fri: alarm!.repeatDays[5], sat: alarm!.repeatDays[6], identifier: alarm!.identifier)
            //add alarm as per date picker time
            alarm?.setTime(date: datePicker.date)
            delegate?.alarmViewControllerDone(alarm: alarm!)
        }

        
        

        
        //go back to alarm view
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func datePickerValueChanged(_ sender: Any) {

    }
    
}