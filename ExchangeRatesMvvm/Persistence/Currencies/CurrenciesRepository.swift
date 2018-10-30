//
//  CurrenciesRepository.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 24/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import Foundation
import CoreData
import RxSwift


//TODO: return some Cursor instead of [Currency] and rewrite CoreDataRepository to use NSFetchedResultsConttroller wrapped in that cursor
protocol CurrenciesRepositoryProtocol {
    func save(currencies: [Currency], completion: ErrorCallback?)
    func getSelectedCurrencies(completion: ListCallback<Currency>?)
    func getOtherCurrencies(completion: ListCallback<Currency>?)
    func markCurrency(withCode code: String, selected: Bool, completion: ItemCallback<Currency>?)
}


class InMemoryCurrenciesRepository: CurrenciesRepositoryProtocol {
    
    private var items = [Currency]()
    private let lock = DispatchQueue(label: "StorageAccessQueue")
    
    func save(currencies: [Currency], completion: ErrorCallback?) {
        self.lock.async {
            self.items.removeAll(where: { item in
                !currencies.contains(where: { $0.code == item.code })
            })
            
            for newItem in currencies {
                if let sameIndex = self.items.firstIndex(where: { $0.code == newItem.code }) {
                    let sameItem = self.items[sameIndex]
                    self.items[sameIndex] = Currency(code: newItem.code, name: newItem.name, selected: sameItem.selected)
                }
                else {
                    self.items.append(newItem)
                }
            }
            
            completion?(nil)
        }
    }
    
    func getSelectedCurrencies(completion: ListCallback<Currency>?) {
        getCurrencies(selected: true, completion: completion)
    }
    
    func getOtherCurrencies(completion: ListCallback<Currency>?) {
        getCurrencies(selected: false, completion: completion)
    }
    
    func markCurrency(withCode code: String, selected: Bool, completion: ItemCallback<Currency>?) {
        self.lock.async {
            if let sameIndex = self.items.firstIndex(where: { $0.code == code }) {
                let sameItem = self.items[sameIndex]
                let updatedItem = Currency(code: sameItem.code, name: sameItem.name, selected: selected)
                self.items[sameIndex] = updatedItem
                completion?(updatedItem, nil)
            }
            else {
                completion?(nil, nil)
            }
        }
    }
    
    private func getCurrencies(selected: Bool, completion: ListCallback<Currency>?) {
        self.lock.async {
            let items = self.items.filter({ $0.selected == selected })
            completion?(items, nil)
        }
    }
}


class CoreDataCurrenciesRepository: CurrenciesRepositoryProtocol {
    
    private let dataManager: CoreDataManagerProtocol
    
    private let sortByCodeDescriptor = NSSortDescriptor(key: "code", ascending: true)
    
    init(dataManager: CoreDataManagerProtocol) {
        self.dataManager = dataManager
    }
    
    func save(currencies: [Currency], completion: ErrorCallback?) {
        self.dataManager.performInBackground({ context in
            
            let currencies = currencies.sorted(by: { $0.code < $1.code })
            
            do {
                let request: NSFetchRequest<CurrencyDb> = CurrencyDb.fetchRequest()
                request.sortDescriptors = [self.sortByCodeDescriptor]
                let entities = try context.fetch(request)
                
                for entity in entities {
                    if !currencies.contains(where: { $0.code == entity.code }) {
                        context.delete(entity)
                    }
                }
                
                for item in currencies {
                    if let sameItem = entities.first(where: { $0.code == item.code }) {
                        sameItem.name = item.name
                    }
                    else {
                        let currency = CurrencyDb(context: context)
                        currency.loadData(from: item)
                        context.insert(currency)
                    }
                }
                
                self.dataManager.save(temporaryContext: context, completion: completion)
            }
            catch {
                debugPrint("Failed to save currencies: ", error)
                completion?(error)
            }
        })
    }
    
    func getSelectedCurrencies(completion: ListCallback<Currency>?) {
        let predicate = NSPredicate(format: "selected == true")
        getCurrencies(by: predicate, completion: completion)
    }
    
    func getOtherCurrencies(completion: ListCallback<Currency>?) {
        let predicate = NSPredicate(format: "selected == false")
        getCurrencies(by: predicate, completion: completion)
    }
    
    func markCurrency(withCode code: String, selected: Bool, completion: ItemCallback<Currency>?) {
        self.dataManager.performInBackground({ context in
            do {
                if let entity = try self.getCurrency(byCode: code, from: context) {
                    
                    entity.selected = selected
                    let updatedCurrency = entity.toDomainObject()
                    
                    self.dataManager.save(temporaryContext: context, completion: { error in
                        if let error = error {
                            completion?(nil, error)
                        }
                        else {
                            completion?(updatedCurrency, nil)
                        }
                    })
                }
                else {
                    completion?(nil, nil)
                }
            }
            catch {
                debugPrint("Failed to update currency selection: ", error)
                completion?(nil, error)
            }
        })
    }
    
    func getCurrency(byCode code: String, from context: NSManagedObjectContext) throws -> CurrencyDb? {
        var currency: CurrencyDb? = nil
        
        let request: NSFetchRequest<CurrencyDb> = CurrencyDb.fetchRequest()
        request.predicate = NSPredicate(format: "code == %@", code)
        request.fetchLimit = 1
        
        currency = try context.fetch(request).first
        
        return currency
    }
    
    private func getCurrencies(by predicate: NSPredicate, completion: ListCallback<Currency>?) {
        self.dataManager.performInBackground({ context in
            do {
                let request: NSFetchRequest<CurrencyDb> = CurrencyDb.fetchRequest()
                request.predicate = predicate
                request.sortDescriptors = [self.sortByCodeDescriptor]
                
                let entities = try context.fetch(request)
                let currencies = entities.compactMap({ $0.toDomainObject() })
                completion?(currencies, nil)
            }
            catch {
                debugPrint("Failed to fetch currencies: ", error)
                completion?([Currency](), error)
            }
        })
    }
}
