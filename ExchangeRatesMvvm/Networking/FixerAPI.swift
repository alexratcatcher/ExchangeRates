//
//  FixerAPI.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 26/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import Foundation
import RxSwift


protocol FixerApiProtocol {
    func perform<T:FixerApiResponse>(request: FixerApiRequest, decodeTo type: T.Type) -> Observable<T>
}


class FixerAPI : FixerApiProtocol {
    
    private let urlSession: URLSession
    
    init(session: URLSession) {
        self.urlSession = session
    }
    
    func perform<T:FixerApiResponse>(request: FixerApiRequest, decodeTo type: T.Type) -> Observable<T> {
        return Observable.create({ observer in
            
            guard let urlRequest = request.urlRequest else {
                let error = NetworkingError.badRequest(path: request.path)
                observer.onError(error)
                return Disposables.create()
            }
            
            let task = self.urlSession.dataTask(with: urlRequest, completionHandler: { data, response, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                
                guard let data = data else {
                    observer.onError(NetworkingError.emptyResponse)
                    return
                }
                
                var decodedResponse: T
                do {
                    let jsonDecoder = JSONDecoder()
                    decodedResponse = try jsonDecoder.decode(T.self, from: data)
                }
                catch {
                    observer.onError(error)
                    return
                }
                
                if let error = decodedResponse.error {
                    let apiError = error.toNetworkingError()
                    observer.onError(apiError)
                }
                else {
                    observer.onNext(decodedResponse)
                    observer.onCompleted()
                }
            })
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        })
    }
}
