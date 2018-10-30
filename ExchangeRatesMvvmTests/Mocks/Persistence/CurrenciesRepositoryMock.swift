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
    func save(currencies: [Currency], completion: ErrorCallback?) {
        getSelectedCurrenciesResultToReturn = currencies.filter({ $0.selected })
        getOtherCurrenciesResultToReturn = currencies.filter({ !$0.selected })
        
        saveCurrenciesDidCalled += 1
        saveCurrenciesArgument = currencies
        
        completion?(saveCurrenciesErrorToReturn)
    }
    
    var getSelectedCurrenciesDidCalled = 0
    var getSelectedCurrenciesResultToReturn = [Currency]()
    var getSelectedCurrenciesErrorToReturn: Error?
    func getSelectedCurrencies(completion: (([Currency], Error?) -> ())?) {
        getSelectedCurrenciesDidCalled += 1
        completion?(getSelectedCurrenciesResultToReturn, getSelectedCurrenciesErrorToReturn)
    }
    
    var getOtherCurrenciesDidCalled = 0
    var getOtherCurrenciesResultToReturn = [Currency]()
    var getOtherCurrenciesErrorToReturn: Error?
    func getOtherCurrencies(completion: (([Currency], Error?) -> ())?) {
        getOtherCurrenciesDidCalled += 1
        completion?(getOtherCurrenciesResultToReturn, getOtherCurrenciesErrorToReturn)
    }
    
    
    var markCurrencySelectedDidCalled = 0
    var markCurrencySelectedCodeArgument: String?
    var markCurrencySelectedSelectedArgument: Bool?
    var markCurrencySelectedResultToReturn: Currency!
    var markCurrencySelectedErrorToReturn: Error?
    func markCurrency(withCode code: String, selected: Bool, completion: ((Currency?, Error?) -> ())?) {
        markCurrencySelectedDidCalled += 1
        markCurrencySelectedCodeArgument = code
        markCurrencySelectedSelectedArgument = selected
        completion?(markCurrencySelectedResultToReturn, markCurrencySelectedErrorToReturn)
        
    }
}
