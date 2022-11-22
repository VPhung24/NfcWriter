//
//  MyContactViewController.swift
//  NfcWriter
//
//  Created by Vivian Phung on 10/27/22.
//

import UIKit
import Contacts
import ContactsUI
import CoreNFC

protocol MyContactViewControllerDelegate: AnyObject {
    func dismissView()
    func editContact()
}

class MyContactViewController: UIViewController {
    weak var delegate: MyContactViewControllerDelegate?
    var tagManager: NFCTagManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        let tagNfcButton = UIButton(buttonStyle: .writeNfc)
        tagNfcButton.addTarget(self, action: #selector(writeNFC), for: .touchUpInside)
        tagNfcButton.accessibilityLabel = NFCButtonStyle.writeNfc.accessibilityLabel
        tagNfcButton.accessibilityHint = NFCButtonStyle.writeNfc.accessibilityHint

        let editButton = UIButton(buttonStyle: .contacts)
        editButton.addTarget(self, action: #selector(editContact), for: .touchUpInside)
        editButton.accessibilityLabel = NFCButtonStyle.contacts.accessibilityLabel
        editButton.accessibilityHint = NFCButtonStyle.contacts.accessibilityHint

        let buttonStackView = UIStackView(frame: CGRect(x: 20, y: 20, width: view.bounds.width - 40, height: (UIScreen.main.bounds.height / 3) - 40), forAxis: .horizontal)

        let modalBackgroundView = UIView(frame: .zero)
        modalBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        modalBackgroundView.backgroundColor = .systemBackground
        modalBackgroundView.layer.cornerRadius = 20

        self.view.addSubview(modalBackgroundView)
        modalBackgroundView.addSubview(buttonStackView)

        buttonStackView.addArrangedSubview(tagNfcButton)
        buttonStackView.addArrangedSubview(editButton)

        NSLayoutConstraint.activate([
            modalBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            modalBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            modalBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            modalBackgroundView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 3),

            buttonStackView.centerXAnchor.constraint(equalTo: modalBackgroundView.centerXAnchor),
            buttonStackView.centerYAnchor.constraint(equalTo: modalBackgroundView.centerYAnchor)
        ])
    }

    @objc func writeNFC() {
        print("nfc writing here")
        let fileRef = storageRef.child("contacts/\(UIDevice.current.identifierForVendor!.uuidString).vcf")

        fileRef.getData(maxSize: 500) { thefile, _ in
            guard thefile != nil else { return }

            fileRef.downloadURL { contactURL, _ in
                guard let contactURL = contactURL else { return }

                guard NFCNDEFReaderSession.readingAvailable else {
                    let alertController = UIAlertController(
                        title: "Scanning Not Supported",
                        message: "This device doesn't support tag scanning.",
                        preferredStyle: .alert
                    )
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    return
                }

                self.tagManager = NFCTagManager(url: contactURL.absoluteString)
            }
        }
    }

    @objc func editContact() {
        delegate?.editContact()
    }
}
