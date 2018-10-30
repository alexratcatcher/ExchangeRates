//
//  CurrenciesService.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 24/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import Foundation
import RxSwift


protocol CurrenciesServiceProtocol {
    func loadCurrencies() -> Observable<[Currency]>
}


class CurrenciesService: CurrenciesServiceProtocol {
    
    private let service: FixerApiProtocol
    
    init(networkingService: FixerApiProtocol) {
        self.service = networkingService
    }
    
    func loadCurrencies() -> Observable<[Currency]> {
        let request = FixerApiRequest(path: "symbols", parameters: [:])
        
        return service.perform(request: request, decodeTo: FixerCurrenciesListResponse.self)
            .map({ response in
                var currencies = [Currency]()
                
                if let symbols = response.symbols, !symbols.isEmpty {
                    currencies = symbols
                        .map({ Currency(code: $0.key, name: $0.value, selected: false) })
                        .sorted(by: { $0.code < $1.code })
                }
                return currencies
            })
    }
}


fileprivate struct FixerCurrenciesListResponse : FixerApiResponse {    
    let success: Bool?
    let error: FixerErrorEntity?
    let symbols: [String : String]?
}
