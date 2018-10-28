//
//  StoryboardInstantiable.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 26/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import UIKit


protocol StoryboardInstantiable {
    static func instantiateFromStoryboard(named: String) -> Self
}


extension StoryboardInstantiable where Self: UIViewController {
    
    static func instantiateFromStoryboard(named: String) -> Self {
        let storyboard = UIStoryboard(name: named, bundle: nil)
        
        let className = String(describing: Self.self)
        let classNameWithoutModule = String(className.split(separator: ".").last!)
        
        let vc = storyboard.instantiateViewController(withIdentifier: classNameWithoutModule) as! Self
        return vc
    }
}
