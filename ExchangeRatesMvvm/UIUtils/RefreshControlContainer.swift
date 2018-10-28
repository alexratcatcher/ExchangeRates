//
//  RefreshControlContainer.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 26/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import UIKit


protocol RefreshControlContainer {
    
    var refreshControl: UIRefreshControl { get }
    
    func showProgress()
    func hideProgress()
}


extension RefreshControlContainer where Self: UIViewController {
    
    func showProgress() {
        if !refreshControl.isRefreshing {
            refreshControl.beginRefreshing()
        }
    }
    
    func hideProgress() {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
}
