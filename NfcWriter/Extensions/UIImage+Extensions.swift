//
//  UIImage+Extensions.swift
//  NfcWriter
//
//  Created by Vivian Phung on 11/22/22.
//

import UIKit

extension UIImage {
    convenience init(systemName: String, pointSize: CGFloat) {
        self.init(systemName: systemName, withConfiguration: UIImage.SymbolConfiguration(pointSize: pointSize, weight: .bold, scale: .large))!
    }
}
