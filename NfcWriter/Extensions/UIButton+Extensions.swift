//
//  UIButton+Extensions.swift
//  NfcWriter
//
//  Created by Vivian Phung on 2/16/23.
//

import UIKit

extension UIButton {
    static func nfcAccessor(type: NFCAccessoryType, primaryAction: UIAction?) -> UIButton {
        let button = UIButton(primaryAction: primaryAction)
        button.backgroundColor = type.backgroundColor
        button.layer.cornerRadius = 20
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .center
        button.setImage(type.image, for: .normal)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.imageView?.adjustsImageSizeForAccessibilityContentSizeCategory = true
        button.accessibilityLabel = type.accessibilityLabel
        button.accessibilityHint = type.accessibilityHint
        return button
    }
}
