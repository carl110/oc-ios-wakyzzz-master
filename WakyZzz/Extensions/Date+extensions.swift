//
//  Date+extensions.swift
//  WakyZzz
//
//  Created by Carl Wainwright on 26/06/2019.
//  Copyright © 2019 Olga Volkova OC. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    
    //set date as string
    func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

