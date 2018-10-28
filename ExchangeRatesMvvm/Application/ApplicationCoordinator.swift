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
    let currenciesRepository: CurrenciesRepositoryProtocol
    let ratesRepository: ExchangeRatesRepositoryProtocol

    let window: UIWindow
    let rootViewController: UINavigationController
    let ratesCoordinator: ExchangeRatesListCoordinator
    
    init(window: UIWindow) {
        self.window = window
        
        let urlSession = URLSession.shared
        fixerService = FixerApiService(session: urlSession)
        currenciesService = CurrenciesService(networkingService: fixerService)
        ratesService = ExchangeRatesService(networkingService: fixerService)
        
        coreDataManager = CoreDataManager()
        let coreDataCurrenciesRepo = CoreDataCurrenciesRepository(dataManager: coreDataManager)
        currenciesRepository = coreDataCurrenciesRepo
        ratesRepository = CoreDataExchangeRatesRepository(dataManager: coreDataManager,
                                                          currenciesRepository: coreDataCurrenciesRepo)
        
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
