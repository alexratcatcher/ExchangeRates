//
//  FixerApiCommons.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 26/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import Foundation


fileprivate let baseUrl = "http://data.fixer.io/api/"
fileprivate let accessKey = "08272530684804e5b779bd5982b0e7fb"


struct FixerApiRequest {
    let path: String
    let parameters: [String : String]
}

extension FixerApiRequest {
    var urlRequest: URLRequest? {
        var request: URLRequest? = nil
        
        let fullPath = baseUrl + self.path
        if var urlComponents = URLComponents(string: fullPath) {
            
            var queryItems = [URLQueryItem]()
            queryItems.append(URLQueryItem(name: "access_key", value: accessKey))
            for (key, value) in self.parameters {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
            urlComponents.queryItems = queryItems
            
            if let url = urlComponents.url {
                request = URLRequest(url: url)
            }
        }
        
        return request
    }
}


protocol FixerApiResponse: Codable {
    var success: Bool? { get }
    var error: FixerErrorEntity? { get }
}


struct FixerErrorEntity : Codable {
    let code: Int?
    let info: String?
}


extension FixerErrorEntity {
    func toNetworkingError() -> NetworkingError {
        return NetworkingError.apiError(code: code ?? 0,
                                        message: info ?? LS("NETWORK_ERROR_UNKNOWN_API_ERROR"))
    }
}
