//
//  ExchangeRateTableViewCell.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 25/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import UIKit



class ExchangeRateTableViewCell: UITableViewCell, ReusableCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    
    func show(rate: ExchangeRateCellViewModel) {
        self.dateLabel.text = DateFormatter.withFormat("dd.MM.yyyy").string(from: rate.date)
        self.rateLabel.text = NumberFormatter.withMoneyFormat().string(for: rate.rate as NSDecimalNumber)
    }
}
