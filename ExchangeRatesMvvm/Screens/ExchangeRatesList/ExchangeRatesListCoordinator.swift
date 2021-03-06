//
//  ExchangeRatesListCoordinator.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 25/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import UIKit


class ExchangeRatesListCoordinator: Coordinator {
    
    private let navigationRoot: UINavigationController
    
    private let currenciesService: CurrenciesServiceProtocol
    private let ratesService: ExchangeRatesServiceProtocol
    
    private let currenciesRepository: RxCurrenciesRepositoryProtocol
    private let ratesRepository: RxExchangeRatesRepositoryProtocol
    
    init(navigationRoot: UINavigationController,
         currenciesService: CurrenciesServiceProtocol,
         ratesService: ExchangeRatesServiceProtocol,
         currenciesRepository: RxCurrenciesRepositoryProtocol,
         ratesRepository: RxExchangeRatesRepositoryProtocol) {
        
        self.navigationRoot = navigationRoot
        
        self.currenciesService = currenciesService
        self.ratesService = ratesService
        
        self.currenciesRepository = currenciesRepository
        self.ratesRepository = ratesRepository
    }
    
    func start() {
        let ratesVC = ExchangeRatesListViewController.instantiateFromStoryboard(named: "ExchangeRatesList")
        ratesVC.title = LS("RATES_SCREEN_TITLE")
        
        let viewModel = ExchangeRatesListViewModel(service: ratesService,
                                                   currenciesRepository: currenciesRepository,
                                                   ratesRepository: ratesRepository)
        ratesVC.viewModel = viewModel
        
        ratesVC.onSettingsPressedBlock = {
            self.openSettingsScreen()
        }
        
        navigationRoot.pushViewController(ratesVC, animated: true)
    }
    
    func openSettingsScreen() {
        let currenciesCoordinator = CurrenciesListCoordinator(navigationRoot: navigationRoot,
                                                              service: currenciesService,
                                                              currenciesRepository: currenciesRepository)
        currenciesCoordinator.start()
    }
}
