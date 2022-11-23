//
//  TwitterProfileModel.swift
//  NfcWriter
//
//  Created by Vivian Phung on 10/17/22.
//

import Foundation
import UIKit

class TwitterProfileModel: Hashable, Codable {
    var username: String
    var name: String
    var profileImageURL: String
    var image: UIImage?

    init(username: String, name: String, profileImageURL: String) {
        self.username = username
        self.name = name
        self.profileImageURL = profileImageURL
    }

    private enum CodingKeys: String, CodingKey {
        case username = "screen_name"
        case profileImageURL = "profile_image_url_https"
        case name
        case image
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(username, forKey: .username)
        try container.encode(profileImageURL, forKey: .profileImageURL)
    }

    required init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        name = try keyedContainer.decode(String.self, forKey: .name)
        username = try keyedContainer.decode(String.self, forKey: .username)
        profileImageURL = try keyedContainer.decode(String.self, forKey: .profileImageURL)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(username)
        hasher.combine(image)
    }

    static func == (lhs: TwitterProfileModel, rhs: TwitterProfileModel) -> Bool {
        lhs.username == rhs.username
    }
}
