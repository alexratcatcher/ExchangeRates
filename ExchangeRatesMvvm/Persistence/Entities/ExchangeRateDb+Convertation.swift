//
//  ExchangeRateDb+Convertation.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 27/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import Foundation


extension ExchangeRateDb {
    
    func toDomainObject() -> ExchangeRate? {
        guard let currency = self.currency?.toDomainObject(),
            let date = self.date,
            let rate = self.rate as Decimal? else {
                return nil
        }
        return ExchangeRate(currency: currency, date: date, rate: rate)
    }
    
    func loadData(from rate: ExchangeRate) {
        self.date = rate.date
        self.rate = NSDecimalNumber(decimal: rate.rate)
    }
}

