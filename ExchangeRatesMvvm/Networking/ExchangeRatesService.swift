//
//  ExchangeRatesService.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 25/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import Foundation
import RxSwift


protocol ExchangeRatesServiceProtocol {
    func loadExchangeRates(for currencies: [Currency], at date: Date) -> Observable<[ExchangeRate]>
}


class ExchangeRatesService: ExchangeRatesServiceProtocol {
    
    private let service: FixerApiServiceProtocol
    
    init(networkingService: FixerApiServiceProtocol) {
        self.service = networkingService
    }
    
    func loadExchangeRates(for currencies: [Currency], at date: Date) -> Observable<[ExchangeRate]> {
        let path = DateFormatter.withFormat("yyyy-MM-dd").string(from: date)
        let parameters = ["symbols" : currencies.map({ $0.code }).joined(separator: ",")]
        let request = FixerApiRequest(path: path, parameters: parameters)
        
        return service.perform(request: request, decodeTo: FixerRatesListResponse.self)
            .map({ response in
                var rates = [ExchangeRate]()
                
                if let ratesDict = response.rates, !ratesDict.isEmpty {
                    for currency in currencies {
                        if let rate = ratesDict[currency.code] {
                            let result = ExchangeRate(currency: currency, date: date, rate: rate)
                            rates.append(result)
                        }
                    }
                }
                return rates
            })
    }
}


fileprivate struct FixerRatesListResponse : FixerApiResponse {
    let success: Bool?
    let error: FixerErrorEntity?
    let rates: [String : Decimal]?
}
