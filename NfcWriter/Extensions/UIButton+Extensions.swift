//
//  UIButton+Extensions.swift
//  NfcWriter
//
//  Created by Vivian Phung on 2/16/23.
//

import UIKit

extension UIButton {
    func nfcAccessory(type: NFCAccessoryType) -> UIButton {
        backgroundColor = type.backgroundColor
        layer.cornerRadius = 20
        imageView?.contentMode = .scaleAspectFit
        contentHorizontalAlignment = .center
        setImage(type.image, for: .normal)
        titleLabel?.adjustsFontForContentSizeCategory = true
        imageView?.adjustsImageSizeForAccessibilityContentSizeCategory = true
        accessibilityLabel = type.accessibilityLabel
        accessibilityHint = type.accessibilityHint
        return self
    }
}
