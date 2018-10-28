//
//  CurrenciesListCoordinator.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 24/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import UIKit


class CurrenciesListCoordinator: Coordinator {
    
    private let navigationRoot: UINavigationController
    private let currenciesService: CurrenciesServiceProtocol
    private let currenciesRepository: CurrenciesRepositoryProtocol
    
    init(navigationRoot: UINavigationController,
         service: CurrenciesServiceProtocol,
         currenciesRepository: CurrenciesRepositoryProtocol) {
        
        self.navigationRoot = navigationRoot
        self.currenciesService = service
        self.currenciesRepository = currenciesRepository
    }
    
    func start() {
        let currenciesListVC = CurrenciesListViewController.instantiateFromStoryboard(named: "CurrenciesList")
        currenciesListVC.title = LS("CURRENCIES_SCREEN_TITLE")
        
        let viewModel = CurrenciesListViewModel(service: currenciesService, currenciesRepository: currenciesRepository)
        currenciesListVC.viewModel = viewModel
        
        navigationRoot.pushViewController(currenciesListVC, animated: true)
    }
}
