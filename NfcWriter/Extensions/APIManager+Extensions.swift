//
//  APIManager.swift
//  NfcWriter
//
//  Created by Vivian Phung on 10/17/22.
//

import UIKit
import VivNetworkExtensions

extension APIManager {

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

        let urlRequest: URLRequest = networkRequest(baseURL: "https://api.twitter.com/", endpoint: TwitterAPIEndpoint.getHandlesForString, parameters: parameters, headers: header)
        networkTask(request: urlRequest, endpoint: TwitterAPIEndpoint.getHandlesForString) { (response: [TwitterProfileModel]?, error) in
            completionHandler(response, error)
        }
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
