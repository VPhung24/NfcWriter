//
//  ContactNFCTaggingViewController.swift
//  NfcWriter
//
//  Created by Vivian Phung on 10/27/22.
//

import UIKit
import Contacts
import ContactsUI

class ContactNFCTaggingViewController: UIViewController {
    weak var delegate: NFCAccessoryTypeDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        let writeNftButton = UIButton.nfcAccessor(type: .writeNfc, primaryAction: UIAction(handler: { [weak self] (_) in
            self?.delegate?.nfcButtonSelected(type: .writeNfc)
        }))

        let editContactButton = UIButton.nfcAccessor(type: .editContact, primaryAction: UIAction(handler: { [weak self] (_) in
            self?.delegate?.nfcButtonSelected(type: .writeContact)
        }))

        let buttonStackView = UIStackView(arrangedSubViews: [writeNftButton, editContactButton],
                                          axis: .horizontal,
                                          distribution: .fillEqually)

        let modalBackgroundView = UIView(frame: .zero)
        modalBackgroundView.backgroundColor = .clear
        modalBackgroundView.layer.cornerRadius = 20

        view.addSubviewWithConstraints(modalBackgroundView, [
            modalBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            modalBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            modalBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            modalBackgroundView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 3)
        ])

        modalBackgroundView.addSubviewWithInsets(buttonStackView)
    }
}
