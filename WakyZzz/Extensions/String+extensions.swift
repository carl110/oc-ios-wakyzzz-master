//
//  String+extensions.swift
//  WakyZzz
//
//  Created by Carl Wainwright on 25/06/2019.
//  Copyright © 2019 Olga Volkova OC. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    //compares string value
    func isEqualToString(find: String) -> Bool {
        return String(format: self) == find
    }
}
