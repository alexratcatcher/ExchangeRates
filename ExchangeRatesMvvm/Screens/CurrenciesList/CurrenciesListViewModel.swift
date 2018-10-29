//
//  CurrenciesListViewModel.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 24/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources


struct CurrenciesSectionViewModel {
    var title: String
    var items: [CurrencyCellViewModel]
    
    init(title: String, items: [CurrencyCellViewModel]) {
        self.title = title
        self.items = items
    }
}


extension CurrenciesSectionViewModel: AnimatableSectionModelType {
    typealias Item = CurrencyCellViewModel
    typealias Identity = String
    
    public var identity: String {
        return title
    }
    
    public init(original: CurrenciesSectionViewModel, items: [CurrencyCellViewModel]) {
        self.title = original.title
        self.items = items
    }
    
    public var hashValue: Int {
        return title.hashValue
    }
}


enum CurrencyCellViewModel {
    case noCurrenciesCell(message: String)
    case currencyCell(currency: CurrencyViewModel)
}


extension CurrencyCellViewModel: Equatable {
    static func == (lhs: CurrencyCellViewModel, rhs: CurrencyCellViewModel) -> Bool {
        switch (lhs, rhs) {
        case (.noCurrenciesCell(let lhsMessage), .noCurrenciesCell(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.currencyCell(let lhsCurrency), .currencyCell(let rhsCurrency)):
            return lhsCurrency == rhsCurrency
        default:
            return false
        }
    }
}


extension CurrencyCellViewModel: IdentifiableType {
    typealias Identity = String
    
    var identity: String {
        switch self {
        case .noCurrenciesCell(message: let message):
            return message
        case .currencyCell(currency: let currency):
            return currency.code
        }
    }
}


struct CurrencyViewModel: Equatable {
    let code: String
    let name: String
    var selected: Bool
}


fileprivate extension CurrencyViewModel {
    
    init(from currency: Currency) {
        code = currency.code
        name = currency.name
        selected = currency.selected
    }
}


class CurrenciesListViewModel {
    
    private let service: CurrenciesServiceProtocol
    private let currenciesRepository: CurrenciesRepositoryProtocol
    
    // Input
    let update = BehaviorRelay(value: ())
    let selectItem = PublishRelay<CurrencyViewModel>()
    
    // Output
    let sections = BehaviorRelay(value: [CurrenciesSectionViewModel]())
    let loading = BehaviorRelay(value: true)
    let error = PublishRelay<Error>()
    
    private let disposeBag = DisposeBag()

    init(service: CurrenciesServiceProtocol,
         currenciesRepository: CurrenciesRepositoryProtocol) {
        self.service = service
        self.currenciesRepository = currenciesRepository
        
        self.bindListUpdate()
        self.bindItemSelection()
    }
    
    private func bindListUpdate() {
        let showCachedCurrencies = self.getCachedCurrencies()
            .do(onNext: { [weak self] data in
                self?.sections.accept(data)
            })
        
        let updateCurrencies = self.updateCurrencies()
        
        update
            .flatMapLatest({
                showCachedCurrencies
            })
            .flatMap({ _ in
                updateCurrencies
            })
            .flatMap({ _ in
                showCachedCurrencies
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private func bindItemSelection() {
        selectItem
            .flatMap({ [currenciesRepository] currencyModel in
                currenciesRepository.markCurrency(withCode: currencyModel.code, selected: !currencyModel.selected)
            })
            .bind(onNext: { [weak self] currency in
                self?.updateCurrency(currency)
            })
            .disposed(by: disposeBag)
    }
    
    private func getCachedCurrencies() -> Observable<[CurrenciesSectionViewModel]> {
        let cellPreparation = prepareCellModels
        
        let flow = Observable.zip(currenciesRepository.getSelectedCurrencies(),
                                  currenciesRepository.getOtherCurrencies())
            .map({ selected, others -> ([CurrencyCellViewModel], [CurrencyCellViewModel]) in
                let selectedCells = cellPreparation(selected, true)
                let otherCells = cellPreparation(others, false)
                return (selectedCells, otherCells)
            })
            .map({ selectedCells, otherCells -> [CurrenciesSectionViewModel] in
                let selectedSection = CurrenciesSectionViewModel(title: LS("CURRENCIES_SCREEN_SELECTED"), items: selectedCells)
                let othersSection = CurrenciesSectionViewModel(title: LS("CURRENCIES_SCREEN_OTHERS"), items: otherCells)
                return [selectedSection, othersSection]
            })
            .catchError({ [weak self] error in
                self?.error.accept(error)
                return Observable.just([CurrenciesSectionViewModel]())
            })
        return flow
    }
    
    private func updateCurrencies() -> Observable<Void> {
        let flow = service.loadCurrencies()
            .do(onNext: { [weak self] _ in
                self?.loading.accept(false)
            })
            .flatMap({ [currenciesRepository] currencies in
                currenciesRepository.save(currencies: currencies)
            })
            .catchError({ [weak self] error in
                self?.loading.accept(false)
                self?.error.accept(error)
                return Observable.just(())
            })
        return flow
    }
    
    private func prepareCellModels(from currencies: [Currency], selected: Bool) -> [CurrencyCellViewModel] {
        if currencies.isEmpty {
            let message = selected
                ? LS("CURRENCIES_SCREEN_NO_SELECTED")
                : LS("CURRENCIES_SCREEN_NO_CURRENCIES")
            let noCurrenciesCell = CurrencyCellViewModel.noCurrenciesCell(message: message)
            return [noCurrenciesCell]
        }
        else {
            let cells = currencies.map({ CurrencyCellViewModel.currencyCell(currency: CurrencyViewModel(from: $0)) })
            return cells
        }
    }
    
    private func updateCurrency(_ currency: Currency) { //some difficult logic for our immutable structures and arrays
        let sections = self.sections.value
        
        var updatedSections = [CurrenciesSectionViewModel]()
        var itemFound = false
        
        for section in sections {
            if itemFound {
                updatedSections.append(section)
            }
            else {
                var currencies = section.items
                
                for index in 0..<currencies.count {
                    var item = currencies[index]
                    if case var CurrencyCellViewModel.currencyCell(currency: itemCurrency) = item, itemCurrency.code == currency.code {
                        itemCurrency.selected = currency.selected
                        item = CurrencyCellViewModel.currencyCell(currency: itemCurrency)
                        currencies[index] = item
                        itemFound = true
                        break
                    }
                }
                
                let updatedSection = CurrenciesSectionViewModel(original: section, items: currencies)
                updatedSections.append(updatedSection)
            }
        }
        
        if itemFound {
            self.sections.accept(updatedSections)
        }
    }
}
