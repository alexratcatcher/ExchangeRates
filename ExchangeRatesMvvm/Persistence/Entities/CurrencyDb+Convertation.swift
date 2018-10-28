//
//  CurrencyDb+Convertation.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 27/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import Foundation


extension CurrencyDb {
    
    func toDomainObject() -> Currency? {
        guard let code = self.code, let name = self.name else {
            return nil
        }
        return Currency(code: code, name: name, selected: selected)
    }
    
    func loadData(from currency: Currency) {
        code = currency.code
        name = currency.name
        selected = currency.selected
    }
}
