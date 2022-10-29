//
//  NFCViewStyle.swift
//  NfcWriter
//
//  Created by Vivian Phung on 10/28/22.
//

import UIKit

extension UIStackView {
    convenience init(frame: CGRect, forAxis axix: NSLayoutConstraint.Axis) {
        self.init(frame: frame)

            self.alignment = .fill
            self.distribution = .fillEqually
            self.axis = axix
            self.spacing = 20

        
    }
}
