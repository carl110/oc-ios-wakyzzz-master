//
//  UIDatePicker+extensions.swift
//  WakyZzz
//
//  Created by Carl Wainwright on 27/06/2019.
//  Copyright © 2019 Olga Volkova OC. All rights reserved.
//

import Foundation
import UIKit


extension UIDatePicker {
    
    //set date/time on datepicker
    func setNewDate(from string: String, format: String, animated: Bool = true) {
        let formater = DateFormatter()
        formater.dateFormat = format
        let date = formater.date(from: string) ?? Date()
        setDate(date, animated: animated)
    }
}
