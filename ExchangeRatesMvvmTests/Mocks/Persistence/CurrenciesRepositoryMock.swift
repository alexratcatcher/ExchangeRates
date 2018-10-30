//
//  CurrenciesRepositoryMock.swift
//  ExchangeRatesMvvmTests
//
//  Created by Alexey Berkov on 27/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import Foundation
import RxSwift


@testable import ExchangeRatesMvvm


class CurrenciesRepositoryMock: CurrenciesRepositoryProtocol {
    
    var saveCurrenciesDidCalled = 0
    var saveCurrenciesArgument: [Currency]?
    var saveCurrenciesErrorToReturn: Error?
    func save(currencies: [Currency]) -> Observable<Void> {
        getSelectedCurrenciesResultToReturn = currencies.filter({ $0.selected })
        getOtherCurrenciesResultToReturn = currencies.filter({ !$0.selected })
        
        saveCurrenciesDidCalled += 1
        saveCurrenciesArgument = currencies
        
        if let error = saveCurrenciesErrorToReturn {
            return Observable.error(error)
        }
        
        return Observable.just(())
    }
    
    var getSelectedCurrenciesDidCalled = 0
    var getSelectedCurrenciesResultToReturn = [Currency]()
    var getSelectedCurrenciesErrorToReturn: Error?
    func getSelectedCurrencies() -> Observable<[Currency]> {
        getSelectedCurrenciesDidCalled += 1
        
        if let error = getSelectedCurrenciesErrorToReturn {
            return Observable.error(error)
        }
        
        return Observable.just(getSelectedCurrenciesResultToReturn)
    }
    
    var getOtherCurrenciesDidCalled = 0
    var getOtherCurrenciesResultToReturn = [Currency]()
    var getOtherCurrenciesErrorToReturn: Error?
    func getOtherCurrencies() -> Observable<[Currency]> {
        getOtherCurrenciesDidCalled += 1
        
        if let error = getOtherCurrenciesErrorToReturn {
            return Observable.error(error)
        }
        
        return Observable.just(getOtherCurrenciesResultToReturn)
    }
    
    var markCurrencySelectedDidCalled = 0
    var markCurrencySelectedCodeArgument: String?
    var markCurrencySelectedSelectedArgument: Bool?
    var markCurrencySelectedResultToReturn: Currency!
    var markCurrencySelectedErrorToReturn: Error?
    func markCurrency(withCode code: String, selected: Bool) -> Observable<Currency> {
        markCurrencySelectedDidCalled += 1
        markCurrencySelectedCodeArgument = code
        markCurrencySelectedSelectedArgument = selected
        
        if let error = markCurrencySelectedErrorToReturn {
            return Observable.error(error)
        }
        
        return Observable.just(markCurrencySelectedResultToReturn)
    }
}
