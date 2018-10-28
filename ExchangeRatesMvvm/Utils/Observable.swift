//
//  Observable.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 24/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import Foundation


class ObservableProperty<T> {
    
    typealias ObserverBlock = (T)->Void
    
    var value: T {
        didSet {
            let newValue = value
            DispatchQueue.main.async {
                self.onValueChanged?(newValue)
            }
        }
    }
    private var onValueChanged: ObserverBlock?
    
    init(value: T) {
        self.value = value
    }
    
    func bind(_ observerBlock: @escaping ObserverBlock) {
        onValueChanged = observerBlock
        observerBlock(value)
    }
    
    func unbind() {
        onValueChanged = nil
    }
}
