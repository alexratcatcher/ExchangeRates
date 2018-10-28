//
//  UIViewController+Alert.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 24/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import UIKit


extension UIViewController {
    
    func showErrorAlert(with message: String, completion: (()->Void)? = nil) {
        guard self.presentedViewController == nil else {
            return
        }
        
        let alert = UIAlertController(title: LS("ALERT_TITLE_ERROR"), message: message, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: LS("ALERT_CLOSE_BUTTON"), style: .cancel, handler: nil)
        alert.addAction(closeAction)
        self.present(alert, animated: true, completion: completion)
    }
}
