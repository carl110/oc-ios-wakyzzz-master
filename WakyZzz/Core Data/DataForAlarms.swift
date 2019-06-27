//
//  DataForAlarms.swift
//  WakyZzz
//
//  Created by Carl Wainwright on 25/06/2019.
//  Copyright © 2019 Olga Volkova OC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DataForAlarms {
    
    var time: Int32
    var enabled: Bool
    var sun: Bool
    var mon: Bool
    var tue: Bool
    var wed: Bool
    var thu: Bool
    var fri: Bool
    var sat: Bool
    var identifier: String
    
    init(object: NSManagedObject) {
        self.time = object.value(forKey: "time") as! Int32
        self.enabled = object.value(forKey: "enabled") as! Bool
        self.sun = object.value(forKey: "repeatSun") as! Bool
        self.mon = object.value(forKey: "repeatMon") as! Bool
        self.tue = object.value(forKey: "repeatTue") as! Bool
        self.wed = object.value(forKey: "repeatWed") as! Bool
        self.thu = object.value(forKey: "repeatThu") as! Bool
        self.fri = object.value(forKey: "repeatFri") as! Bool
        self.sat = object.value(forKey: "repeatSat") as! Bool
        self.identifier = object.value(forKey: "identifier") as! String
    }
}
