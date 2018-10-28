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
    func getRates() -> Observable<[ExchangeRate]>
    
    func saveRates(_ rates: [ExchangeRate]) -> Observable<Void>
    
    func deleteRates(forDatesBefore date: Date) -> Observable<Void>
    func deleteRates(for currency: Currency) -> Observable<Void>
    func deleteRatesForNotSelectedCurrencies() -> Observable<Void>
    func deleteAllRates() -> Observable<Void>
}


//let it be here for some time
class InMemoryExchangeRatesRepository: ExchangeRatesRepositoryProtocol {
    
    private var items = [ExchangeRate]()
    private let lock = DispatchQueue(label: "StorageAccessQueue")
    
    func getRates() -> Observable<[ExchangeRate]> {
        return Observable.create({ observer in
            self.lock.async {
                observer.onNext(self.items)
                observer.onCompleted()
            }
            return Disposables.create()
        })
    }
    
    func saveRates(_ rates: [ExchangeRate]) -> Observable<Void> {
        return Observable.create({ observer in
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
                observer.onNext(())
                observer.onCompleted()
            }
            return Disposables.create()
        })
    }
    
    func deleteRatesForNotSelectedCurrencies() -> Observable<Void> {
        return Observable.create({ observer in
            self.lock.async {
                self.items.removeAll(where: { !$0.currency.selected })
                observer.onNext(())
                observer.onCompleted()
            }
            return Disposables.create()
        })
    }
    
    func deleteRates(forDatesBefore date: Date) -> Observable<Void> {
        return Observable.create({ observer in
            self.lock.async {
                self.items.removeAll(where: { $0.date < date })
                observer.onNext(())
                observer.onCompleted()
            }
            return Disposables.create()
        })
    }
    
    func deleteRates(for currency: Currency) -> Observable<Void> {
        return Observable.create({ observer in
            self.lock.async {
                self.items.removeAll(where: { $0.currency.code == currency.code })
                observer.onNext(())
                observer.onCompleted()
            }
            return Disposables.create()
        })
    }
    
    func deleteAllRates() -> Observable<Void> {
        return Observable.create({ observer in
            self.lock.async {
                self.items.removeAll()
                observer.onNext(())
                observer.onCompleted()
            }
            return Disposables.create()
        })
    }
}


class CoreDataExchangeRatesRepository: ExchangeRatesRepositoryProtocol {

    private let dataManager: CoreDataManagerProtocol
    private let currenciesRepository: CoreDataCurrenciesRepository
    
    init(dataManager: CoreDataManagerProtocol, currenciesRepository: CoreDataCurrenciesRepository) {
        self.dataManager = dataManager
        self.currenciesRepository = currenciesRepository
    }
    
    func getRates() -> Observable<[ExchangeRate]> {
        return Observable.create({ observer in
            self.dataManager.performInBackground({ context in
                do {
                    let request: NSFetchRequest<ExchangeRateDb> = ExchangeRateDb.fetchRequest()
                    request.sortDescriptors = [NSSortDescriptor(key: "currency.code", ascending: true),
                                               NSSortDescriptor(key: "date", ascending: false)]
                    
                    let entities = try context.fetch(request)
                    
                    let rates = entities.compactMap({ $0.toDomainObject() })
                    observer.onNext(rates)
                    observer.onCompleted()
                }
                catch {
                    debugPrint("Failed to get rates: ", error)
                    observer.onError(error)
                }
            })
            return Disposables.create()
        })
    }
    
    func saveRates(_ rates: [ExchangeRate]) -> Observable<Void> {
        return Observable.create({ observer in
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
                    
                    self.dataManager.save(temporaryContext: context, completion: { error in
                        if let error = error {
                            observer.onError(error)
                        }
                        else {
                            observer.onNext(())
                            observer.onCompleted()
                        }
                    })
                }
                catch {
                    debugPrint("Failed to save rates: ", error)
                    observer.onError(error)
                }
            })
            return Disposables.create()
        })
    }
    
    func deleteRates(forDatesBefore date: Date) -> Observable<Void> {
        let predicate = NSPredicate(format: "date < %@", date as NSDate)
        return deleteRates(byPredicate: predicate)
    }
    
    func deleteRates(for currency: Currency) -> Observable<Void> {
        let predicate = NSPredicate(format: "currency.code == %@", currency.code)
        return deleteRates(byPredicate: predicate)
    }
    
    func deleteRatesForNotSelectedCurrencies() -> Observable<Void> {
        let predicate = NSPredicate(format: "currency.selected == false")
        return deleteRates(byPredicate: predicate)
    }
    
    func deleteAllRates() -> Observable<Void> {
        return deleteRates(byPredicate: nil)
    }
    
    private func deleteRates(byPredicate predicate: NSPredicate?) -> Observable<Void> {
        return Observable.create({ observer in
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
                    
                    self.dataManager.save(temporaryContext: context, completion: { error in
                        if let error = error {
                            observer.onError(error)
                        }
                        else {
                            observer.onNext(())
                            observer.onCompleted()
                        }
                    })
                }
                catch {
                    debugPrint("Failed to delete rates: ", error)
                    observer.onError(error)
                }
            })
            return Disposables.create()
        })
    }
}
