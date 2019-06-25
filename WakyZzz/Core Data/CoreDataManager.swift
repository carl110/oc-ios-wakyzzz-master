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
    
    func saveAlarm(time: Int32, enabled: Bool, sun: Bool, mon: Bool, tue: Bool, wed: Bool, thu: Bool, fri: Bool, sat: Bool) {
        
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
            let tasks = try managedContext.fetch(fetchRequest)
            var taskObjects: [DataForAlarms] = []
            
            tasks.forEach { (taskObject) in
                taskObjects.append(DataForAlarms(object: taskObject))
            }
            
            return taskObjects
        } catch let error as NSError {
            print ("Could not fetch. \(error) \(error.userInfo)")
            return nil
        }
        
    }
    
}
