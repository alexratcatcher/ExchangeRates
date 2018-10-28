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
    
    var mainThreadContext: NSManagedObjectContext { get }
    var temporaryContext: NSManagedObjectContext { get }
    
    func performInBackground(_ block: @escaping (NSManagedObjectContext) -> Void)
    func save(temporaryContext: NSManagedObjectContext, completion: ((Error?) -> Void)?)
    
    func saveMasterContext()
}


class CoreDataManager: CoreDataManagerProtocol {
    
    private let storageName = "ExchangeRatesMvvm.sqlite"
    private let modelName = "ExchangeRatesMvvm"
    
    private lazy var applicationSupportDirectory: URL = {
        let urls = FileManager.default.urls(for:  .applicationSupportDirectory, in: .userDomainMask)
        return urls.last!
    }()
    
    private lazy var databaseLocation: URL = {
        applicationSupportDirectory.appendingPathComponent(storageName)
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption: true,
                           NSInferMappingModelAutomaticallyOption: true]
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: databaseLocation, options: options)
        } catch {
            debugPrint(error)
            abort()//TODO:
        }
        return coordinator
    }()
    
    private lazy var masterContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        context.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        return context
    }()
    
    
    lazy var mainThreadContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = self.masterContext
        context.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        return context
    }()
    
    var temporaryContext: NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = self.mainThreadContext
        context.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        return context
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
