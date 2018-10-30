//
//  ExchangeRatesRepository.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 25/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import Foundation
import CoreData
import RxSwift


//TODO: return some Cursor instead of [ExchangeRate] and rewrite CoreDataRepository to use NSFetchedResultsConttroller wrapped in that cursor
protocol ExchangeRatesRepositoryProtocol {
    func getRates(completion: ListCallback<ExchangeRate>?)
    
    func saveRates(_ rates: [ExchangeRate], completion: ErrorCallback?)
    
    func deleteRates(forDatesBefore date: Date, completion: ErrorCallback?)
    func deleteRates(for currency: Currency, completion: ErrorCallback?)
    func deleteRatesForNotSelectedCurrencies(completion: ErrorCallback?)
    func deleteAllRates(completion: ErrorCallback?)
}


class InMemoryExchangeRatesRepository: ExchangeRatesRepositoryProtocol {
    
    private var items = [ExchangeRate]()
    private let lock = DispatchQueue(label: "StorageAccessQueue")
    
    func getRates(completion: ListCallback<ExchangeRate>?) {
        self.lock.async {
            completion?(self.items, nil)
        }
    }
    
    func saveRates(_ rates: [ExchangeRate], completion: ErrorCallback?) {
        self.lock.async {
            for rate in rates {
                if let sameItemIndex = self.items.firstIndex(where: { $0.currency.code == rate.currency.code && $0.date == rate.date }) {
                    var sameItem = self.items[sameItemIndex]
                    sameItem.rate = rate.rate
                    self.items[sameItemIndex] = sameItem
                }
                else {
                    self.items.append(rate)
                }
            }
            completion?(nil)
        }
    }
    
    func deleteRates(forDatesBefore date: Date, completion: ErrorCallback?) {
        self.lock.async {
            self.items.removeAll(where: { $0.date < date })
            completion?(nil)
        }
    }
    
    func deleteRates(for currency: Currency, completion: ErrorCallback?) {
        self.lock.async {
            self.items.removeAll(where: { $0.currency.code == currency.code })
            completion?(nil)
        }
    }
    
    func deleteRatesForNotSelectedCurrencies(completion: ErrorCallback?) {
        self.lock.async {
            self.items.removeAll(where: { !$0.currency.selected })
            completion?(nil)
        }
    }
    
    func deleteAllRates(completion: ErrorCallback?) {
        self.lock.async {
            self.items.removeAll()
            completion?(nil)
        }
    }
}


class CoreDataExchangeRatesRepository: ExchangeRatesRepositoryProtocol {

    private let dataManager: CoreDataManagerProtocol
    private let currenciesRepository: CoreDataCurrenciesRepository
    
    init(dataManager: CoreDataManagerProtocol, currenciesRepository: CoreDataCurrenciesRepository) {
        self.dataManager = dataManager
        self.currenciesRepository = currenciesRepository
    }
    
    func getRates(completion: ListCallback<ExchangeRate>?) {
        self.dataManager.performInBackground({ context in
            do {
                let request: NSFetchRequest<ExchangeRateDb> = ExchangeRateDb.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(key: "currency.code", ascending: true),
                                           NSSortDescriptor(key: "date", ascending: false)]
                
                let entities = try context.fetch(request)
                
                let rates = entities.compactMap({ $0.toDomainObject() })
                completion?(rates, nil)
            }
            catch {
                debugPrint("Failed to get rates: ", error)
                completion?([ExchangeRate](), error)
            }
        })
    }
    
    func saveRates(_ rates: [ExchangeRate], completion: ErrorCallback?) {
        self.dataManager.performInBackground({ context in
            do {
                let request: NSFetchRequest<ExchangeRateDb> = ExchangeRateDb.fetchRequest()
                
                let entities = try context.fetch(request)
                
                for item in rates {
                    if let sameItem = entities.first(where: { ($0.currency?.code == item.currency.code) && ($0.date == item.date) }) {
                        sameItem.loadData(from: item)
                    }
                    else if let currency = try self.currenciesRepository.getCurrency(byCode: item.currency.code, from: context) {
                        let rate = ExchangeRateDb(context: context)
                        rate.currency = currency
                        rate.loadData(from: item)
                        context.insert(rate)
                    }
                }
                
                self.dataManager.save(temporaryContext: context, completion: completion)
            }
            catch {
                debugPrint("Failed to save rates: ", error)
                completion?(error)
            }
        })
    }
    
    func deleteRates(forDatesBefore date: Date, completion: ErrorCallback?) {
        let predicate = NSPredicate(format: "date < %@", date as NSDate)
        deleteRates(byPredicate: predicate, completion: completion)
    }
    
    func deleteRates(for currency: Currency, completion: ErrorCallback?) {
        let predicate = NSPredicate(format: "currency.code == %@", currency.code)
        deleteRates(byPredicate: predicate, completion: completion)
    }
    
    func deleteRatesForNotSelectedCurrencies(completion: ErrorCallback?) {
        let predicate = NSPredicate(format: "currency.selected == false")
        deleteRates(byPredicate: predicate, completion: completion)
    }
    
    func deleteAllRates(completion: ErrorCallback?) {
        deleteRates(byPredicate: nil, completion: completion)
    }
    
    private func deleteRates(byPredicate predicate: NSPredicate?, completion: ErrorCallback?) {
        self.dataManager.performInBackground({ context in
            do {
                let request: NSFetchRequest<ExchangeRateDb> = ExchangeRateDb.fetchRequest()
                request.predicate = predicate
                request.returnsObjectsAsFaults = true
                request.includesPropertyValues = false
                
                let entities = try context.fetch(request)
                for entity in entities {
                    context.delete(entity)
                }
                
                self.dataManager.save(temporaryContext: context, completion: completion)
            }
            catch {
                debugPrint("Failed to delete rates: ", error)
                completion?(error)
            }
        })
    }
}
