//
//  CoreDataManager.swift
//  WakyZzz
//
//  Created by Carl Wainwright on 24/06/2019.
//  Copyright © 2019 Olga Volkova OC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CoreDataManager {
    
    class var shared: CoreDataManager {
        struct Singleton {
            static let instance = CoreDataManager()
        }
        return Singleton.instance
    }
    
    func saveAlarm(time: Int32, enabled: Bool, sun: Bool, mon: Bool, tue: Bool, wed: Bool, thu: Bool, fri: Bool, sat: Bool, identifier: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "WakyZzz", in: managedContext)!
        let managedObject = NSManagedObject(entity: entity, insertInto: managedContext)
        
        managedObject.setValue(time, forKey: "time")
        managedObject.setValue(enabled, forKey: "enabled")
        managedObject.setValue(sun, forKey: "repeatSun")
        managedObject.setValue(mon, forKey: "repeatMon")
        managedObject.setValue(tue, forKey: "repeatTue")
        managedObject.setValue(wed, forKey: "repeatWed")
        managedObject.setValue(thu, forKey: "repeatThu")
        managedObject.setValue(fri, forKey: "repeatFri")
        managedObject.setValue(sat, forKey: "repeatSat")
        managedObject.setValue(identifier, forKey: "identifier")
        do {
            try managedContext.save()
        } catch {
            let error = error as NSError
            fatalError("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func fetchAlarmData() -> [DataForAlarms]? {
        let appDelegate =
            UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WakyZzz")
        do {
            let alarms = try managedContext.fetch(fetchRequest)
            var alarmObjects: [DataForAlarms] = []
            alarms.forEach { (alarmObject) in
                alarmObjects.append(DataForAlarms(object: alarmObject))
            }
            return alarmObjects
        } catch let error as NSError {
            print ("Could not fetch. \(error) \(error.userInfo)")
            return nil
        }
    }
    
    func fetchIndividualAlarm(time: Int32) -> [DataForAlarms]? {
        //Fetch data for selected time
        let appDelegate =
            UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        
        let predicate = NSPredicate(format: "time = %i", time)
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WakyZzz")
        fetchRequest.predicate = predicate
        do {
            let alarms = try managedContext.fetch(fetchRequest)
            var alarmObjects: [DataForAlarms] = []
            
            alarms.forEach { (alarmObject) in
                alarmObjects.append(DataForAlarms(object: alarmObject))
            }
            return alarmObjects
        } catch let error as NSError {
            print ("Could not fetch. \(error) \(error.userInfo)")
            return nil
        }
    }
    
    func fetchAlarmFromID(id: String) -> [DataForAlarms]? {
        //Fetch data for selected time
        let appDelegate =
            UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        let predicate = NSPredicate(format: "identifier = %@", id)
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WakyZzz")
        fetchRequest.predicate = predicate
        do {
            let alarms = try managedContext.fetch(fetchRequest)
            var alarmObjects: [DataForAlarms] = []
            
            alarms.forEach { (alarmObject) in
                alarmObjects.append(DataForAlarms(object: alarmObject))
            }
            return alarmObjects
        } catch let error as NSError {
            print ("Could not fetch. \(error) \(error.userInfo)")
            return nil
        }
    }
    
    func deleteAlarm(id: String) {
        let appDelegate =
            UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "WakyZzz")
        let predicate = NSPredicate(format: "identifier = %@", id)
        fetchRequest.predicate = predicate
        do{
            let result = try managedContext.fetch(fetchRequest)
            if result.count > 0{
                for object in result {
                    managedContext.delete(object as! NSManagedObject)
                }
                do {
                    try managedContext.save()
                }
            }
        }catch {
            let error = error as NSError
            fatalError("Could not delete. \(error), \(error.userInfo)")
        }
    }
    
    func turnOffOneTimeAlarm(id: String) {
        //set enabled button to false
        let appDelegate =
            UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        let predicate = NSPredicate(format: "identifier = %@", id)
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WakyZzz")
        fetchRequest.predicate = predicate
        do {
            let alarms = try managedContext.fetch(fetchRequest)
            if let alarm = alarms.last {
                alarm.setValue(false, forKey: "enabled")
                do {
                    try managedContext.save()
                } catch {
                    let error = error as NSError
                    fatalError("Could not save. \(error), \(error.userInfo)")
                }
            }
        } catch let error as NSError {
            print ("Could not fetch. \(error). \(error.userInfo)")
        }
    }
    
    func  updateAlarmRepeatDays(id: String, time: Int32, sun: Bool, mon: Bool, tue: Bool, wed: Bool, thu: Bool, fri: Bool, sat: Bool) {
        //Update data held in coredata
        let appDelegate =
            UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        let predicate = NSPredicate(format: "identifier = %@", id)
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WakyZzz")
        fetchRequest.predicate = predicate
        do {
            let alarms = try managedContext.fetch(fetchRequest)
            if let alarm = alarms.last {
                alarm.setValue(time, forKey: "time")
                alarm.setValue(sun, forKey: "repeatSun")
                alarm.setValue(mon, forKey: "repeatMon")
                alarm.setValue(tue, forKey: "repeatTue")
                alarm.setValue(wed, forKey: "repeatWed")
                alarm.setValue(thu, forKey: "repeatThu")
                alarm.setValue(fri, forKey: "repeatFri")
                alarm.setValue(sat, forKey: "repeatSat")
                alarm.setValue(true, forKeyPath: "enabled")
                do {
                    try managedContext.save()
                } catch {
                    let error = error as NSError
                    fatalError("Could not save. \(error), \(error.userInfo)")
                }
            }
        } catch let error as NSError {
            print ("Could not fetch. \(error). \(error.userInfo)")
        }
    }
    
    func  updateAlarmEnabled(id: String, enabled: Bool) {
        //Update data held in coredata
        let appDelegate =
            UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        let predicate = NSPredicate(format: "identifier = %@", id)
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WakyZzz")
        fetchRequest.predicate = predicate
        do {
            let alarms = try managedContext.fetch(fetchRequest)
            if let alarm = alarms.last {
                alarm.setValue(enabled, forKeyPath: "enabled")
                do {
                    try managedContext.save()
                } catch {
                    let error = error as NSError
                    fatalError("Could not save. \(error), \(error.userInfo)")
                }
            }
        } catch let error as NSError {
            print ("Could not fetch. \(error). \(error.userInfo)")
        }
    }
}


