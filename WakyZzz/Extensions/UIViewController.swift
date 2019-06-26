//
//  UIViewController.swift
//  WakyZzz
//
//  Created by Carl Wainwright on 26/06/2019.
//  Copyright © 2019 Olga Volkova OC. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    //get time in Int 32 format from date
    func getTime(date: Date) -> Int32 {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.hour, .minute, .month, .year, .day, .second, .weekOfMonth], from: date as Date)
        
        return Int32(components.hour! * 3600 + components.minute! * 60)
    }
}
