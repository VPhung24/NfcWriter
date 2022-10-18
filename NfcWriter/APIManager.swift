//
//  APIManager.swift
//  NfcWriter
//
//  Created by Vivian Phung on 10/17/22.
//

import Foundation

class APIManager {
    static let shared = APIManager()
    
    // force using shared instance
    private init() {}
        
    private let twitterAPIURL = "https://api.twitter.com/"
    
    // API calls

    func searchforTwitterHandle(forString input: String, completionHandler: @escaping ([TwitterHandleModel]?, Error?) -> Void) {
        let parameters: [String: Any] = ["q": input, "page": "1", "count": "10"]

        guard let bearerToken: String = Bundle.main.infoDictionary?["BEARER_TOKEN"] as? String else { return }
        let header: [String: String] = ["Authorization": bearerToken]

        let urlRequest: URLRequest = networkRequest(baseURL: twitterAPIURL, endpoint: TwitterAPIEndpoint.GetHandlesForString, parameters: parameters, headers: header)
        networkTask(request: urlRequest) { (response: [TwitterHandleModel]?, error) in
            completionHandler(response, error)
        }
    }
    
    // Networking
    
    func networkRequest(baseURL: String, endpoint: Endpoint, parameters: [String: Any]? = nil, headers: [String: String]? = nil) -> URLRequest {
        var components = URLComponents(string: baseURL + endpoint.path)!
        guard let parameters = parameters else {
            return requestBuilder(url: components.url!, endpoint: endpoint, headers: headers)
        }
        components.queryItems = parameters.map {
            URLQueryItem(name: $0, value: "\($1)")
        }
        
        return requestBuilder(url: components.url!, endpoint: endpoint, headers: headers)
    }
    
    func requestBuilder(url: URL, endpoint: Endpoint, headers: [String: String]? = nil) -> URLRequest {
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        headers?.forEach {
            request.addValue($1, forHTTPHeaderField: $0)
        }
        return request as URLRequest
    }
    
    func networkTask<T: Codable>(request: URLRequest, completionHandler: @escaping (T?, Error?) -> Void) {
        let session: URLSession = URLSession.shared
        
        let task = session.dataTask(with: request) { data, response, error in
            guard let responseData = data, error == nil else {
                completionHandler(nil, error)
                return
            }
                        
            let decoder = JSONDecoder()
            do {
                let jsonData: T = try decoder.decode(T.self, from: responseData)
                completionHandler(jsonData, nil)
            } catch let error { // catches decoding error from the try
                completionHandler(nil, error)
            }
        }
        task.resume()
    }
}

enum Method: String {
    case GET
    case POST
}

protocol Endpoint {
    var path: String { get }
    var method: Method { get }
    
}

enum TwitterAPIEndpoint: Endpoint {
    case GetInfoForHandle, GetHandlesForString
    
    var path: String {
        switch self {
        case .GetInfoForHandle:
            return "2/users/by"
        case .GetHandlesForString:
            return "1.1/users/search.json"
        }
    }
    
    var method: Method {
        switch self {
        case .GetInfoForHandle, .GetHandlesForString:
            return .GET
        }
    }
}
