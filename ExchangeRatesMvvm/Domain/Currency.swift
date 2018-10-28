//
//  Currency.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 24/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import Foundation


struct Currency: Equatable, Hashable {
    let code: String
    let name: String
    let selected: Bool
}
