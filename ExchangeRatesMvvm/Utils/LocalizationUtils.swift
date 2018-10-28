//
//  LocalizationUtils.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 24/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import Foundation


func LS(_ string: String) -> String {
    return NSLocalizedString(string, tableName: "LocalizedTexts", comment: string)
}
