//
//  EndpointManager.swift
//  NfcWriter
//
//  Created by Vivian Phung on 10/18/22.
//

import Foundation

enum Method: String {
    case GET
    case POST
}

protocol Endpoint {
    var path: String { get }
    var method: Method { get }
    
}

// MARK: - TwitterAPIEndpoint
enum TwitterAPIEndpoint: Endpoint {
    case GetInfoForHandle, GetHandlesForString, GetProfilePhoto
    
    var path: String {
        switch self {
        case .GetInfoForHandle:
            return "2/users/by"
        case .GetHandlesForString:
            return "1.1/users/search.json"
        default:
            return ""
        }
    }
    
    var method: Method {
        switch self {
        default:
            return .GET
        }
    }
}
