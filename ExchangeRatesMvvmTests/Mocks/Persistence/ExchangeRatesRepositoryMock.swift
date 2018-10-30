//
//  ExchangeRatesRepositoryMock.swift
//  ExchangeRatesMvvmTests
//
//  Created by Alexey Berkov on 27/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import Foundation
import RxSwift


@testable import ExchangeRatesMvvm


class ExchangeRatesRepositoryMock: ExchangeRatesRepositoryProtocol {
    
    var getRatesDidCalled = 0
    var getRatesResultToReturn = [ExchangeRate]()
    var getRatesErrorToReturn: Error?
    func getRates(completion: (([ExchangeRate], Error?) -> ())?) {
        
        getRatesDidCalled += 1
        
        completion?(getRatesResultToReturn, getRatesErrorToReturn)
    }
    
    var saveRatesDidCalled = 0
    var saveRatesArgument: [ExchangeRate]?
    var saveRatesErrorToReturn: Error?
    func saveRates(_ rates: [ExchangeRate], completion: ErrorCallback?) {
        getRatesResultToReturn = rates
        
        saveRatesDidCalled += 1
        saveRatesArgument = rates
        
        completion?(saveRatesErrorToReturn)
    }
    
    var deleteRatesForDatesBeforeDidCalled = 0
    var deleteRatesForDatesBeforeArgument: Date?
    var deleteRatesForDatesBeforeErrorToReturn: Error?
    func deleteRates(forDatesBefore date: Date, completion: ErrorCallback?) {
        getRatesResultToReturn = getRatesResultToReturn.filter({ $0.date > date })
        
        deleteRatesForDatesBeforeDidCalled += 1
        deleteRatesForDatesBeforeArgument = date
        
        completion?(deleteRatesForDatesBeforeErrorToReturn)
    }
    
    var deleteRatesForCurrencyDidCalled = 0
    var deleteRatesForCurrencyArgument: Currency?
    var deleteRatesForCurrencyErrorToReturn: Error?
    func deleteRates(for currency: Currency, completion: ErrorCallback?) {
        getRatesResultToReturn = getRatesResultToReturn.filter({ $0.currency != currency })
        
        deleteRatesForCurrencyDidCalled += 1
        deleteRatesForCurrencyArgument = currency
        
        completion?(deleteRatesForCurrencyErrorToReturn)
    }
    
    var deleteRatesForNotSelectedCurrenciesDidCalled = 0
    var deleteRatesForNotSelectedCurrenciesErrorToReturn: Error?
    func deleteRatesForNotSelectedCurrencies(completion: ErrorCallback?) {
        getRatesResultToReturn = getRatesResultToReturn.filter({ $0.currency.selected })
        
        deleteRatesForNotSelectedCurrenciesDidCalled += 1
        
        completion?(deleteRatesForCurrencyErrorToReturn)
    }
    
    var deleteAllRatesDidCalled = 0
    var deleteAllRatesErrorToReturn: Error?
    func deleteAllRates(completion: ErrorCallback?) {
        getRatesResultToReturn = [ExchangeRate]()
        
        deleteAllRatesDidCalled += 1
        
        completion?(deleteAllRatesErrorToReturn)
    }
}
