//
//  DateFormatterCache.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 25/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import Foundation


fileprivate class DateFormatterCache {
    
    static let instance = DateFormatterCache()
    
    private var formatters = [String : DateFormatter]()
    
    func formatter(withFormat format: String) -> DateFormatter {
        if let cached = formatters[format] {
            return cached
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        formatters[format] = formatter
        
        return formatter
    }
}


extension DateFormatter {
    
    static func withFormat(_ format: String) -> DateFormatter {
        return DateFormatterCache.instance.formatter(withFormat: format)
    }
}
