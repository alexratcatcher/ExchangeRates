//
//  ExchangeRatesListViewModel.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 25/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources


struct ExchangeRatesSectionViewModel {
    var title: String
    var items: [ExchangeRateCellViewModel]
    
    init(title: String, items: [ExchangeRateCellViewModel]) {
        self.title = title
        self.items = items
    }
}


extension ExchangeRatesSectionViewModel: AnimatableSectionModelType {
    typealias Item = ExchangeRateCellViewModel
    typealias Identity = String
    
    public var identity: String {
        return title
    }
    
    public init(original: ExchangeRatesSectionViewModel, items: [ExchangeRateCellViewModel]) {
        self.title = original.title
        self.items = items
    }
    
    public var hashValue: Int {
        return title.hashValue
    }
}


struct ExchangeRateCellViewModel: IdentifiableType, Equatable {
    typealias Identity = String
    
    let identity: String
    let date: Date
    let rate: Decimal
}


class ExchangeRatesListViewModel {
    
    private let service: ExchangeRatesServiceProtocol
    private let currenciesRepository: CurrenciesRepositoryProtocol
    private let ratesRepository: ExchangeRatesRepositoryProtocol
    private let dateProvider: DateProviderProtocol
    
    private let daysCount = 5
    
    // Input
    let update = BehaviorRelay(value: ())
    
    // Output
    let sections = BehaviorRelay(value: [ExchangeRatesSectionViewModel]())
    let loading = BehaviorRelay(value: false)
    let error = PublishRelay<Error>()
    
    private let disposeBag = DisposeBag()
    
    init(service: ExchangeRatesServiceProtocol,
         currenciesRepository: CurrenciesRepositoryProtocol,
         ratesRepository: ExchangeRatesRepositoryProtocol,
         dateProvider: DateProviderProtocol) {
        
        self.service = service
        self.currenciesRepository = currenciesRepository
        self.ratesRepository = ratesRepository
        self.dateProvider = dateProvider
        
        self.bindListUpdate()
    }
    
    private func bindListUpdate() {
        update
            .flatMap({ _ in
                self.ratesRepository.deleteRatesForNotSelectedCurrencies()
            })
            .flatMap({ _ in
                self.getCachedRates()
            })
            .do(onNext: { data in
                self.sections.accept(data)
            })
            .flatMap({ _ in
                self.updateRates()
            })
            .flatMap({ _ in
                self.getCachedRates()
            })
            .catchError({ error in
                self.loading.accept(false)
                self.error.accept(error)
                return Observable.just([ExchangeRatesSectionViewModel]())
            })
            .bind(onNext: { data in
                self.sections.accept(data)
            })
            .disposed(by: disposeBag)
    }
    
    private func getCachedRates() -> Observable<[ExchangeRatesSectionViewModel]> {
        return self.ratesRepository.getRates()
            .map({ rates in
                var groupedByCurrency = [Currency : [ExchangeRate]]()
                for rate in rates {
                    var withSameCurrency = groupedByCurrency[rate.currency] ?? [ExchangeRate]()
                    withSameCurrency.append(rate)
                    groupedByCurrency[rate.currency] = withSameCurrency
                }
                
                var sectionModels = [ExchangeRatesSectionViewModel]()
                for (key, value) in groupedByCurrency {
                    let cellModels = value
                        .map({ rate -> ExchangeRateCellViewModel in
                            //TODO: need to find more effective identifier. But fine for now
                            let identity = rate.currency.code + DateFormatter.withFormat("dd-MM-yyyy").string(from: rate.date)
                            return ExchangeRateCellViewModel(identity: identity, date: rate.date, rate: rate.rate)
                        })
                        .sorted(by: { $0.date > $1.date })
                    let sectionModel = ExchangeRatesSectionViewModel(title: key.name, items: cellModels)
                    sectionModels.append(sectionModel)
                }
                sectionModels.sort(by: { $0.title < $1.title })
                return sectionModels
            })
            .catchError({ error in
                self.error.accept(error)
                return Observable.just([ExchangeRatesSectionViewModel]())
            })
    }
    
    private func updateRates() -> Observable<Void> {
        //Fixer.io don't accepts timezone, so for simplicity we will request for rates in range from yesterday to 6 days ago
        //for current day rate we must use another endpoint
        let now = self.dateProvider.currentDate().addingDays(-1)
        let minDate = now.addingDays(-self.daysCount)
        
        let flow = self.currenciesRepository.getSelectedCurrencies()
            .do(onNext: { _ in
                self.loading.accept(true)
            })
            .flatMap({ currencies -> Observable<[Void]> in
                var updatesTasks = [Observable<Void>]()
                
                for index in 0..<self.daysCount {
                    let date = now.addingDays(-index)
                    let task = self.updateRates(for: currencies, at: date)
                    updatesTasks.append(task)
                }
                
                return Observable.zip(updatesTasks)
            }).flatMap({ _ in
                self.ratesRepository.deleteRates(forDatesBefore: minDate)
            })
            .do(onNext: { _ in
                self.loading.accept(false)
            })
            .catchError({ error in
                self.loading.accept(false)
                self.error.accept(error)
                return Observable.just(())
            })
        return flow
    }
    
    private func updateRates(for currencies: [Currency], at date: Date) -> Observable<Void> {
        return self.service.loadExchangeRates(for: currencies, at: date)
            .flatMap({ rates in
                self.ratesRepository.saveRates(rates)
            })
    }
}
