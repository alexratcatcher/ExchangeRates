//
//  DateProvider.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 25/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import Foundation


//Used to provide timestamp at day start
protocol DateProviderProtocol {
    func currentDate() -> Date
}


class DateProvider: DateProviderProtocol {
    
    private let calendar = Calendar(identifier: .gregorian)
    
    func currentDate() -> Date {
        let now = Date()
        let dayStartDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: now)
        return dayStartDate ?? now
    }
}
