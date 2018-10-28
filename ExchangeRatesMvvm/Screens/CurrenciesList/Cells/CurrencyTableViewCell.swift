//
//  CurrencyTableViewCell.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 24/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import UIKit


class CurrencyTableViewCell: UITableViewCell, ReusableCell {
    
    @IBOutlet private weak var codeLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!

    var currency: CurrencyViewModel! {
        didSet {
            codeLabel.text = currency.code
            nameLabel.text = currency.name
            accessoryType = currency.selected ? .checkmark : .none
        }
    }
}
