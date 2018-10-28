//
//  NumberFormatterCache.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 25/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import Foundation


fileprivate class NumberFormatterCache {
    
    static let instance = NumberFormatterCache()
    
    let moneyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}


extension NumberFormatter {
    
    static func withMoneyFormat() -> NumberFormatter {
        return NumberFormatterCache.instance.moneyFormatter
    }
}
