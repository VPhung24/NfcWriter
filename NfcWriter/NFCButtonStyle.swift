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
    case writeNfc

    func backgroundColor() -> UIColor {
        switch self {
        case .twitter:
            return UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1.0)
        case .contacts:
            return UIColor(red: 175/255, green: 135/255, blue: 74/255, alpha: 1.0)
        case .share:
            return .red
        case .writeNfc:
            return .lightGray
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
        case .writeNfc:
            return UIImage(systemName: "iphone.homebutton.radiowaves.left.and.right", pointSize: 60).withTintColor(.white).withRenderingMode(.alwaysOriginal)
        }
    }

    func accessibilityLabel() -> String {
        switch self {
        case .twitter:
            return "twitter"
        case .contacts:
            return "contact"
        case .share:
            return "share"
        case .writeNfc:
            return "write to nfc"
        }
    }

    func accessibilityHint() -> String {
        switch self {
        case .twitter:
            return "find twitter to write to nfc"
        case .contacts:
            return "write contact to nfc"
        case .share:
            return "share contact"
        case .writeNfc:
            return "write to nfc"
        }
    }
}

extension UIImage {
    convenience init(systemName: String, pointSize: CGFloat) {
        self.init(systemName: systemName, withConfiguration: UIImage.SymbolConfiguration(pointSize: pointSize, weight: .bold, scale: .large))!
    }
}

extension UIButton {
    convenience init(buttonStyle: NFCButtonStyle) {
        self.init(type: .roundedRect)
        self.backgroundColor = buttonStyle.backgroundColor()
        self.layer.cornerRadius = 20
        self.imageView?.contentMode = .scaleAspectFit
        self.contentHorizontalAlignment = .center
        self.imageEdgeInsets = UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
        self.setImage(buttonStyle.image(), for: .normal)
        self.titleLabel?.adjustsFontForContentSizeCategory = true
        self.imageView?.adjustsImageSizeForAccessibilityContentSizeCategory = true
    }
}
