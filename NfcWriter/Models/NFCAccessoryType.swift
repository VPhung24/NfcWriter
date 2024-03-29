//
//  NFCAccessoryType.swift
//  NfcWriter
//
//  Created by Vivian Phung on 10/28/22.
//

import UIKit

protocol NFCAccessoryTypeDelegate: AnyObject {
    func nfcButtonSelected(type: NFCAccessoryType)
}

enum NFCAccessoryType: NSString {
    case twitter
    case writeContact
    case editContact
    case share
    case writeNfc
    case dismiss

    var backgroundColor: UIColor {
        switch self {
        case .twitter:
            return UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1.0)
        case .editContact, .writeContact:
            return UIColor(red: 175/255, green: 135/255, blue: 74/255, alpha: 1.0)
        case .share:
            return .red
        case .writeNfc:
            return .lightGray
        case .dismiss:
            return .white
        }
    }

    var image: UIImage {
        switch self {
        case .twitter:
            return UIImage(named: "twitter_white_logo")!.resizeImageToWidth(newWidth: 100)
        case .editContact, .writeContact:
            return UIImage(systemName: "person.crop.square.filled.and.at.rectangle.fill")!.resizeImageToWidth(newWidth: 100).withTintColor(.white)
        case .writeNfc:
            return UIImage(systemName: "iphone.homebutton.radiowaves.left.and.right")!.resizeImageToWidth(newWidth: 100).withTintColor(.white)
        default:
            return (UIImage(systemName: "square.and.arrow.up.fill")!.resizeImageToWidth(newWidth: 100).withTintColor(.white))
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .twitter:
            return "twitter"
        case .editContact, .writeContact:
            return "contact"
        case .writeNfc:
            return "write to nfc"
        default:
            return "default"
        }
    }

    var accessibilityHint: String {
        switch self {
        case .twitter:
            return "find twitter to write to nfc"
        case .editContact, .writeContact:
            return "write contact to nfc"
        case .writeNfc:
            return "write to nfc"
        default:
            return "default"
        }
    }
}
