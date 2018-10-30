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
    func getRates() -> Observable<[ExchangeRate]> {
        getRatesDidCalled += 1
        return Observable.just(getRatesResultToReturn)
    }
    
    var saveRatesDidCalled = 0
    var saveRatesArgument: [ExchangeRate]?
    var saveRatesErrorToReturn: Error?
    func saveRates(_ rates: [ExchangeRate]) -> Observable<Void> {
        getRatesResultToReturn = rates
        
        saveRatesDidCalled += 1
        saveRatesArgument = rates
        
        if let error = saveRatesErrorToReturn {
            return Observable.error(error)
        }
        
        return Observable.just(())
    }
    
    var deleteRatesForDatesBeforeDidCalled = 0
    var deleteRatesForDatesBeforeArgument: Date?
    var deleteRatesForDatesBeforeErrorToReturn: Error?
    func deleteRates(forDatesBefore date: Date) -> Observable<Void> {
        getRatesResultToReturn = getRatesResultToReturn.filter({ $0.date > date })
        
        deleteRatesForDatesBeforeDidCalled += 1
        deleteRatesForDatesBeforeArgument = date
        
        if let error = deleteRatesForDatesBeforeErrorToReturn {
            return Observable.error(error)
        }
        
        return Observable.just(())
    }
    
    var deleteRatesForCurrencyDidCalled = 0
    var deleteRatesForCurrencyArgument: Currency?
    var deleteRatesForCurrencyErrorToReturn: Error?
    func deleteRates(for currency: Currency) -> Observable<Void> {
        getRatesResultToReturn = getRatesResultToReturn.filter({ $0.currency != currency })
        
        deleteRatesForCurrencyDidCalled += 1
        deleteRatesForCurrencyArgument = currency
        
        if let error = deleteRatesForCurrencyErrorToReturn {
            return Observable.error(error)
        }
        
        return Observable.just(())
    }
    
    var deleteRatesForNotSelectedCurrenciesDidCalled = 0
    var deleteRatesForNotSelectedCurrenciesErrorToReturn: Error?
    func deleteRatesForNotSelectedCurrencies() -> Observable<Void> {
        getRatesResultToReturn = getRatesResultToReturn.filter({ $0.currency.selected })
        
        deleteRatesForNotSelectedCurrenciesDidCalled += 1
        
        if let error = deleteRatesForNotSelectedCurrenciesErrorToReturn {
            return Observable.error(error)
        }
        
        return Observable.just(())
    }
    
    var deleteAllRatesDidCalled = 0
    var deleteAllRatesErrorToReturn: Error?
    func deleteAllRates() -> Observable<Void> {
        getRatesResultToReturn = [ExchangeRate]()
        
        deleteAllRatesDidCalled += 1
        
        if let error = deleteAllRatesErrorToReturn {
            return Observable.error(error)
        }
        
        return Observable.just(())
    }
}
