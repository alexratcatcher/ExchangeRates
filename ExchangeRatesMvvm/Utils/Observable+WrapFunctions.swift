//
//  Observable+WrapFunctions.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 30/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import Foundation
import RxSwift


typealias ListCallback<T> = ([T], Error?)->Void
typealias ItemCallback<T> = (T?, Error?)->Void
typealias ErrorCallback = (Error?)->Void


extension Observable {
    
    static func wrap<T>(block: @escaping (ListCallback<T>?) -> Void) -> Observable<[T]> {
        return Observable<[T]>.create({ observer in
            block({ items, error -> Void in
                if let error = error {
                    observer.onError(error)
                }
                else {
                    observer.onNext(items)
                    observer.onCompleted()
                }
            })
            return Disposables.create()
        })
    }
    
    static func wrap<T>(block: @escaping (ItemCallback<T>?) -> Void) -> Observable<T> {
        return Observable<T>.create({ observer in
            block({ item, error -> Void in
                if let error = error {
                    observer.onError(error)
                }
                else if let item = item {
                    observer.onNext(item)
                    observer.onCompleted()
                }
                else {
                    observer.onCompleted()
                }
            })
            return Disposables.create()
        })
    }
    
    static func wrap(block: @escaping (ErrorCallback?) -> Void) -> Observable<Void> {
        return Observable<Void>.create({ observer in
            block({ error -> Void in
                if let error = error {
                    observer.onError(error)
                }
                else {
                    observer.onNext(())
                    observer.onCompleted()
                }
            })
            return Disposables.create()
        })
    }
}
