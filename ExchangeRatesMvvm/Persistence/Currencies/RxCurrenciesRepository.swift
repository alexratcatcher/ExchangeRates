//
//  RxCurrenciesRepository.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 30/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import Foundation
import RxSwift


protocol RxCurrenciesRepositoryProtocol {
    func save(currencies: [Currency]) -> Observable<Void>
    func getSelectedCurrencies() -> Observable<[Currency]>
    func getOtherCurrencies() -> Observable<[Currency]>
    func markCurrency(withCode code: String, selected: Bool) -> Observable<Currency>
}


class RxCurrenciesRepository: RxCurrenciesRepositoryProtocol {
    
    private let repo: CurrenciesRepositoryProtocol
    
    init(repository: CurrenciesRepositoryProtocol) {
        self.repo = repository
    }
    
    func save(currencies: [Currency]) -> Observable<Void> {
        return Observable<Void>.wrap(block: { [repo] callback in
            repo.save(currencies: currencies, completion: callback)
        })
    }
    
    func getSelectedCurrencies() -> Observable<[Currency]> {
        return Observable<[Currency]>.wrap(block: { [repo] callback in
            repo.getSelectedCurrencies(completion: callback)
        })
    }
    
    func getOtherCurrencies() -> Observable<[Currency]> {
        return Observable<[Currency]>.wrap(block: { [repo] callback in
            repo.getOtherCurrencies(completion: callback)
        })
    }
    
    func markCurrency(withCode code: String, selected: Bool) -> Observable<Currency> {
        return Observable<Currency>.wrap(block: { [repo] callback in
            repo.markCurrency(withCode: code, selected: selected, completion: callback)
        })
    }
}
