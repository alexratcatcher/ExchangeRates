//
//  ExchangeRatesServiceMock.swift
//  ExchangeRatesMvvmTests
//
//  Created by Alexey Berkov on 27/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import Foundation
import RxSwift


@testable import ExchangeRatesMvvm


class ExchangeRatesServiceMock: ExchangeRatesServiceProtocol {
    
    var loadExchangeRatesDidCalled = 0
    var loadExchangeRatesCurrenciesArgument: [Currency]?
    var loadExchangeRatesDateArgument: Date?
    var loadExchangeRatesResultToReturn = [ExchangeRate]()
    var loadExchangeRatesErrorToReturn: Error?
    func loadExchangeRates(for currencies: [Currency], at date: Date) -> Observable<[ExchangeRate]> {
        loadExchangeRatesDidCalled += 1
        loadExchangeRatesCurrenciesArgument = currencies
        loadExchangeRatesDateArgument = date
        
        if let error = loadExchangeRatesErrorToReturn {
            return Observable.error(error)
        }
        
        return Observable.just(loadExchangeRatesResultToReturn)
    }
}
