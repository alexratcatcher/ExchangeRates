//
//  Date+Days.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 26/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import Foundation


extension Date {
    
    func dayStart() -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let dayStartDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: self)
        return dayStartDate ?? self
    }
    
    func addingDays(_ daysCount: Int) -> Date {
        let dayLength = 24*60*60 //not very precise method, but fine for our purposes
        let change = Double(daysCount*dayLength)
        return self.addingTimeInterval(change)
    }
}
