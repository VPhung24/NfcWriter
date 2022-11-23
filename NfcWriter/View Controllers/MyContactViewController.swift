//
//  MyContactViewController.swift
//  NfcWriter
//
//  Created by Vivian Phung on 10/27/22.
//

import UIKit
import Contacts
import ContactsUI

class MyContactViewController: UIViewController {
    weak var delegate: NfcButtonDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        let buttonStackView = UIStackView(arrangedSubViews:
                                            [NfcButton(buttonType: .writeNfc, delegate: self.delegate),
                                             NfcButton(buttonType: .editContact, delegate: self.delegate)],
                                          axis: .horizontal,
                                          distribution: .fillEqually)

        let modalBackgroundView = UIView(frame: .zero)
        modalBackgroundView.backgroundColor = .systemBackground
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
