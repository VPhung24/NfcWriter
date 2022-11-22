//
//  UIButton+Extensions.swift
//  NfcWriter
//
//  Created by Vivian Phung on 11/22/22.
//

import UIKit

extension UIButton {
    convenience init(buttonStyle: NFCButtonStyle) {
        self.init(type: .roundedRect)
        self.backgroundColor = buttonStyle.backgroundColor
        self.layer.cornerRadius = 20
        self.imageView?.contentMode = .scaleAspectFit
        self.contentHorizontalAlignment = .center
        self.imageEdgeInsets = UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
        self.setImage(buttonStyle.image, for: .normal)
        self.titleLabel?.adjustsFontForContentSizeCategory = true
        self.imageView?.adjustsImageSizeForAccessibilityContentSizeCategory = true
    }
}
