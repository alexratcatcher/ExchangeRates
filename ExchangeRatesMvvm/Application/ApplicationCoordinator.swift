//
//  ApplicationCoordinator.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 24/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import UIKit
import CoreData


class ApplicationCoordinator: Coordinator {
    
    let fixerService: FixerApiServiceProtocol
    let currenciesService: CurrenciesServiceProtocol
    let ratesService: ExchangeRatesServiceProtocol
    
    let coreDataManager: CoreDataManagerProtocol
    let currenciesRepository: RxCurrenciesRepositoryProtocol
    let ratesRepository: RxExchangeRatesRepositoryProtocol

    let window: UIWindow
    let rootViewController: UINavigationController
    let ratesCoordinator: ExchangeRatesListCoordinator
    
    init(window: UIWindow) {
        self.window = window
        
        let urlSession = URLSession.shared
        fixerService = FixerApiService(session: urlSession)
        currenciesService = CurrenciesService(networkingService: fixerService)
        ratesService = ExchangeRatesService(networkingService: fixerService)
        
        let coreDataManager = CoreDataManager()
        coreDataManager.prepareStorage()
        self.coreDataManager = coreDataManager
        
        let currenciesRepo = CoreDataCurrenciesRepository(dataManager: coreDataManager)
        currenciesRepository = RxCurrenciesRepository(repository: currenciesRepo)

        let ratesRepo = CoreDataExchangeRatesRepository(dataManager: coreDataManager, currenciesRepository: currenciesRepo)
        ratesRepository = RxExchangeRatesRepository(repository: ratesRepo)
        
        rootViewController = UINavigationController()
        
        ratesCoordinator = ExchangeRatesListCoordinator(navigationRoot: rootViewController,
                                                        currenciesService: currenciesService,
                                                        ratesService: ratesService,
                                                        currenciesRepository: currenciesRepository,
                                                        ratesRepository: ratesRepository)
    }
    
    func start() {
        window.rootViewController = rootViewController
        ratesCoordinator.start()
        window.makeKeyAndVisible()
    }
}
