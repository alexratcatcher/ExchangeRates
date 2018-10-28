//
//  NetworkingError.swift
//  ExchangeRatesMvvm
//
//  Created by Alexey Berkov on 24/10/2018.
//  Copyright © 2018 Alexey Berkov. All rights reserved.
//

import Foundation


enum NetworkingError : Error {
    case badRequest(path: String)
    case emptyResponse
    case wrongResponse
    case apiError(code: Int, message: String)
}


extension NetworkingError : LocalizedError {
    var errorDescription: String? {
        switch self {
        case .badRequest(let path):
            return LS("NETWORK_ERROR_BAD_REQUEST") + path
        case .emptyResponse:
            return LS("NETWORK_ERROR_EMPTY_RESPONSE")
        case .wrongResponse:
            return LS("NETWORK_ERROR_WRONG_RESPONSE")
        case .apiError(code: _, message: let message):
            return message //for now just show raw server message
        }
    }
}
