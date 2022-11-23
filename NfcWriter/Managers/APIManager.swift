//
//  APIManager.swift
//  NfcWriter
//
//  Created by Vivian Phung on 10/17/22.
//

import Foundation
import UIKit

class APIManager {
    static let shared = APIManager()

    // force using shared instance
    private init() {}

    private let twitterAPIURL = "https://api.twitter.com/"

    // MARK: - API Calls
    func getProfileImage(twitterHandleModel: TwitterProfileModel, isFullImage: Bool = false, completionHandler: @escaping (TwitterProfileModel?, Error?) -> Void) {
        let baseURL: String = isFullImage ? twitterHandleModel.profileImageURL.replacingOccurrences(of: "_normal", with: "") : twitterHandleModel.profileImageURL
        let urlRequest: URLRequest = networkRequest(baseURL: baseURL, endpoint: TwitterAPIEndpoint.getProfilePhoto)
        networkTask(request: urlRequest, endpoint: TwitterAPIEndpoint.getProfilePhoto) { (response: Data?, _) in
            if let data = response, let image = UIImage(data: data) {
                twitterHandleModel.image = image
                completionHandler(twitterHandleModel, nil)
                return
            }
            completionHandler(nil, APIError.imageError)
        }
    }

    func searchforTwitterHandle(forString input: String, completionHandler: @escaping ([TwitterProfileModel]?, Error?) -> Void) {
        let parameters: [String: Any] = ["q": input, "page": "1", "count": "10"]

        guard let bearerToken: String = Bundle.main.infoDictionary?["BEARER_TOKEN"] as? String else { return }
        let header: [String: String] = ["Authorization": bearerToken]

        let urlRequest: URLRequest = networkRequest(baseURL: twitterAPIURL, endpoint: TwitterAPIEndpoint.getHandlesForString, parameters: parameters, headers: header)
        networkTask(request: urlRequest, endpoint: TwitterAPIEndpoint.getHandlesForString) { (response: [TwitterProfileModel]?, error) in
            completionHandler(response, error)
        }
    }

    // MARK: - Networking
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

    func networkTask<T: Codable>(request: URLRequest, endpoint: Endpoint, completionHandler: @escaping (T?, Error?) -> Void) {
        let session: URLSession = URLSession.shared

        let task = session.dataTask(with: request) { data, _, error in
            guard let responseData = data, error == nil else {
                completionHandler(nil, error)
                return
            }

            switch endpoint {
            case TwitterAPIEndpoint.getProfilePhoto:
                completionHandler(responseData as? T, nil)
            default:
                let decoder = JSONDecoder()
                do {
                    let jsonData: T = try decoder.decode(T.self, from: responseData)
                    completionHandler(jsonData, nil)
                } catch let error { // catches decoding error from the try
                    completionHandler(nil, error)
                }
            }

        }
        task.resume()
    }
}

// MARK: - Error
enum APIError: Error {
    case imageError
}
