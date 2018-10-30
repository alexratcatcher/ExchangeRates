//
//  CoreDataManager.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 27/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import Foundation
import CoreData


protocol CoreDataManagerProtocol {
    
    var mainThreadContext: NSManagedObjectContext! { get }
    var temporaryContext: NSManagedObjectContext { get }
    
    func performInBackground(_ block: @escaping (NSManagedObjectContext) -> Void)
    func save(temporaryContext: NSManagedObjectContext, completion: ((Error?) -> Void)?)
    
    func saveMasterContext()
}


class CoreDataManager: CoreDataManagerProtocol {
    
    private let storageName = "ExchangeRatesMvvm.sqlite"
    private let modelName = "ExchangeRatesMvvm"
    
    private let coordinator: NSPersistentStoreCoordinator
    
    private(set) var masterContext: NSManagedObjectContext!
    private(set) var mainThreadContext: NSManagedObjectContext!
    
    var temporaryContext: NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = self.mainThreadContext
        context.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        return context
    }
    
    init() {
        let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)!
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
    }
    
    func prepareStorage() throws {
        let applicationSupportDirectory = FileManager.default.urls(for:  .applicationSupportDirectory, in: .userDomainMask).last!
        let databaseLocation = applicationSupportDirectory.appendingPathComponent(storageName)
        

        let options = [NSMigratePersistentStoresAutomaticallyOption: true,
                       NSInferMappingModelAutomaticallyOption: true]
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: databaseLocation, options: options)

        
        let masterContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        masterContext.persistentStoreCoordinator = coordinator
        masterContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        self.masterContext = masterContext
        
        let mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mainContext.parent = self.masterContext
        mainContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        self.mainThreadContext = mainContext
    }
    
    func performInBackground(_ block: @escaping (NSManagedObjectContext) -> Void) {
        DispatchQueue.global(qos: .background).async {
            block(self.temporaryContext)
        }
    }
    
    //MARK: - Saving
    
    func save(temporaryContext: NSManagedObjectContext, completion: ((Error?) -> Void)?) {
        guard temporaryContext.hasChanges else {
            completion?(nil)
            return
        }
        
        temporaryContext.perform {
            do {
                try temporaryContext.save()
                self.saveMainContext(completion: completion)
            } catch {
                completion?(error)
            }
        }
    }
    
    private func saveMainContext(completion: ((Error?) -> Void)?) {
        guard mainThreadContext.hasChanges else {
            completion?(nil)
            return
        }
        
        mainThreadContext.perform {
            do {
                try self.mainThreadContext.save()
                self.saveMasterContext(completion: completion)
            } catch {
                completion?(error)
            }
        }
    }
    
    func saveMasterContext() {
        saveMainContext(completion: nil)
    }
    
    private func saveMasterContext(completion: ((Error?) -> Void)?) {
        guard masterContext.hasChanges else {
            completion?(nil)
            return
        }
        
        masterContext.perform {
            do {
                try self.masterContext.save()
                completion?(nil)
            } catch let error {
                completion?(error)
            }
        }
    }
}
