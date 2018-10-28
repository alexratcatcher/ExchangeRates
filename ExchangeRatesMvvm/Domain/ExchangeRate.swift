//
//  ExchangeRate.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 25/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import Foundation


struct ExchangeRate: Equatable {
    let currency: Currency
    let date: Date
    var rate: Decimal
}
