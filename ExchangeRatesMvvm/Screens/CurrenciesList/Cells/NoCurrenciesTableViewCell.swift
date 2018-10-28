//
//  NoCurrenciesTableViewCell.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 25/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import UIKit


class NoCurrenciesTableViewCell: UITableViewCell, ReusableCell {
    
    @IBOutlet private weak var messageLabel: UILabel!
    
    var message: String! {
        didSet {
            self.messageLabel.text = message
        }
    }
}
