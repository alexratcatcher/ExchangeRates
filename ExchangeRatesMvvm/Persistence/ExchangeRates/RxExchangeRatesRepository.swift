//
//  RxExchangeRatesRepository.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 30/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import Foundation
import RxSwift


protocol RxExchangeRatesRepositoryProtocol {
    func getRates() -> Observable<[ExchangeRate]>
    
    func saveRates(_ rates: [ExchangeRate]) -> Observable<Void>
    
    func deleteRates(forDatesBefore date: Date) -> Observable<Void>
    func deleteRates(for currency: Currency) -> Observable<Void>
    func deleteRatesForNotSelectedCurrencies() -> Observable<Void>
    func deleteAllRates() -> Observable<Void>
}


class RxExchangeRatesRepository: RxExchangeRatesRepositoryProtocol {
    
    private let repo: ExchangeRatesRepositoryProtocol
    
    init(repository: ExchangeRatesRepositoryProtocol) {
        self.repo = repository
    }
    
    func getRates() -> Observable<[ExchangeRate]> {
        return Observable<[ExchangeRate]>.wrap(block: { [repo] callback in
            repo.getRates(completion: callback)
        })
    }
    
    func saveRates(_ rates: [ExchangeRate]) -> Observable<Void> {
        return Observable<Void>.wrap(block: { [repo] callback in
            repo.saveRates(rates, completion: callback)
        })
    }
    
    func deleteRates(forDatesBefore date: Date) -> Observable<Void> {
        return Observable<Void>.wrap(block: { [repo] callback in
            repo.deleteRates(forDatesBefore: date, completion: callback)
        })
    }
    
    func deleteRates(for currency: Currency) -> Observable<Void> {
        return Observable<Void>.wrap(block: { [repo] callback in
            repo.deleteRates(for: currency, completion: callback)
        })
    }
    
    func deleteRatesForNotSelectedCurrencies() -> Observable<Void> {
        return Observable<Void>.wrap(block: { [repo] callback in
            repo.deleteRatesForNotSelectedCurrencies(completion: callback)
        })
    }
    
    func deleteAllRates() -> Observable<Void> {
        return Observable<Void>.wrap(block: { [repo] callback in
            repo.deleteAllRates(completion: callback)
        })
    }
}
