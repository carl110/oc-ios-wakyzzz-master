//
//  WakyZzzTests.swift
//  WakyZzzTests
//
//  Created by Carl Wainwright on 08/07/2019.
//  Copyright © 2019 Olga Volkova OC. All rights reserved.
//

import XCTest
@testable import WakyZzz

class WakyZzzTests: XCTestCase {
    var coreDataManager: CoreDataManager!
    let alarm = Alarm()
    let avc = AlarmsViewController()

    
    func testTimeCalculation() {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let testTime = formatter.date(from: "2000/12/11 10:30")
        let stringTime = avc.getTime(date: testTime!)

        //check getTime func calculates the time from date into and Int (time is hour multiply 3600 eg: 11:30 is 11.5 * 3600 = 41400)
        XCTAssertEqual(stringTime, 37800)
    }

}
