//
//  EndpointManager.swift
//  NfcWriter
//
//  Created by Vivian Phung on 10/18/22.
//

import Foundation
import VivNetworkExtensions

typealias Method = VivNetworkExtensions.Method

// MARK: - TwitterAPIEndpoint
enum TwitterAPIEndpoint: Endpoint {
    case getInfoForHandle, getHandlesForString, getProfilePhoto

    var path: String {
        switch self {
        case .getInfoForHandle:
            return "2/users/by"
        case .getHandlesForString:
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
