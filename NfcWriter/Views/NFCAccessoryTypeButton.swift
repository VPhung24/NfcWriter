//
//  NFCAccessoryTypeButton.swift
//  NfcWriter
//
//  Created by Vivian Phung on 11/22/22.
//

import UIKit

class NFCAccessoryTypeButton: UIButton {
    public var type: NFCAccessoryType
    weak var delegate: NFCAccessoryTypeDelegate?

    required init(buttonType: NFCAccessoryType, delegate: NFCAccessoryTypeDelegate?) {
        self.type = buttonType
        self.delegate = delegate
        super.init(frame: .zero)

        backgroundColor = buttonType.backgroundColor
        layer.cornerRadius = 20
        imageView?.contentMode = .scaleAspectFit
        contentHorizontalAlignment = .center
        imageEdgeInsets = UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
        setImage(buttonType.image, for: .normal)
        titleLabel?.adjustsFontForContentSizeCategory = true
        imageView?.adjustsImageSizeForAccessibilityContentSizeCategory = true

        self.addTarget(self, action: #selector(accessoryTypeButtonTapped), for: .touchDown)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public var accessibilityLabel: String? {
        get {
            return type.accessibilityLabel
        }
        set {
           // Specifically do nothing. We're not "setting a property" we're responding to changes of the internal views.
        }
    }

    override public var accessibilityHint: String? {
        get {
            return type.accessibilityHint
        }
        set {
           // Specifically do nothing. We're not "setting a property" we're responding to changes of the internal views.
        }
    }

    @objc func accessoryTypeButtonTapped() {
        self.delegate?.nfcButtonSelected(ofType: type)
    }
}
