//
//  NFCButtonStyle.swift
//  NfcWriter
//
//  Created by Vivian Phung on 10/28/22.
//

import UIKit

enum NFCButtonStyle: String {
    case twitter
    case contacts
    case share

    func backgroundColor() -> UIColor {
        switch self {
        case .twitter:
            return UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1.0)
        case .contacts:
            return UIColor(red: 175/255, green: 135/255, blue: 74/255, alpha: 1.0)
        case .share:
            return .red
        }
    }

    func image() -> UIImage {
        switch self {
        case .twitter:
            return UIImage(named: "twitter_white_logo")!.withRenderingMode(.alwaysOriginal)
        case .contacts:
            return UIImage(systemName: "person.crop.square.filled.and.at.rectangle.fill", pointSize: 60).withTintColor(.white).withRenderingMode(.alwaysOriginal)
        case .share:
            return UIImage(systemName: "square.and.arrow.up.fill", pointSize: 60).withTintColor(.white).withRenderingMode(.alwaysOriginal)
        }
    }
}

extension UIImage {
    convenience init(systemName: String, pointSize: CGFloat) {
        self.init(systemName: systemName, withConfiguration: UIImage.SymbolConfiguration(pointSize: pointSize, weight: .bold, scale: .large))!
    }
}
