//
//  CurrenciesServiceMock.swift
//  ExchangeRatesMvvmTests
//
//  Created by Alexey Berkov on 27/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import Foundation
import RxSwift


@testable import ExchangeRatesMvvm


class CurrenciesServiceMock: CurrenciesServiceProtocol {
    
    var loadCurrenciesDidCalled = 0
    var loadCurrenciesResultToReturn = [Currency]()
    var loadCurrenciesErrorToReturn: Error?
    func loadCurrencies() -> Observable<[Currency]> {
        loadCurrenciesDidCalled += 1
        
        if let error = loadCurrenciesErrorToReturn {
            return Observable.error(error)
        }
        
        return Observable.just(loadCurrenciesResultToReturn)
    }
}
