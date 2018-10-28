//
//  ReusableCell.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 24/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import UIKit


protocol ReusableCell {
    static var cellIdentifier: String { get }
    static var nib: UINib { get }
}


extension ReusableCell where Self:UITableViewCell {
    
    static var cellIdentifier: String {
        let className = String(describing: Self.self)
        let classNameWithoutModule = String(className.split(separator: ".").last!)
        return classNameWithoutModule
    }
    
    static var nib: UINib {
        return UINib(nibName: cellIdentifier, bundle: nil)
    }
}
