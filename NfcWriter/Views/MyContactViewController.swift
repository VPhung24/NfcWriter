//
//  MyContactViewController.swift
//  NfcWriter
//
//  Created by Vivian Phung on 10/27/22.
//

import UIKit
import Contacts
import ContactsUI

protocol MyContactViewControllerDelegate: AnyObject {
    func dismissView()
    func editContact()
}

class MyContactViewController: UIViewController {
    weak var delegate: MyContactViewControllerDelegate?
    var tagManager: NFCTagManager?
    

    lazy var shareButton: UIButton = {
        let button = UIButton(buttonStyle: .share)
        button.addTarget(self, action: #selector(shareNfcContact), for: .touchUpInside)
        return button
    }()

    lazy var editButton: UIButton = {
        let button = UIButton(buttonStyle: .contacts)
        button.addTarget(self, action: #selector(editContact), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        let buttonStackView = UIStackView(frame: CGRect(x: 20, y: 20, width: view.bounds.width - 40, height: (UIScreen.main.bounds.height / 3) - 40), forAxis: .horizontal)
            
        let modalBackgroundView: UIView = {
            let view = UIView(frame: .zero)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .systemBackground
            view.layer.cornerRadius = 20
            return view
        }()

        self.view.addSubview(modalBackgroundView)
        modalBackgroundView.addSubview(buttonStackView)

        buttonStackView.addArrangedSubview(shareButton)
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

    @objc func shareNfcContact() {
        print("nfc writing here")
        let fileRef = storageRef.child("contacts/\(UIDevice.current.identifierForVendor!.uuidString).vcf")

        fileRef.getData(maxSize: 500) { thefile, _ in
            guard thefile != nil else { return }

            fileRef.downloadURL { contactURL, _ in
                guard let contactURL = contactURL else { return }

                self.tagManager = NFCTagManager(url: contactURL.absoluteString)
            }
        }
    }

    @objc func editContact() {
        delegate?.editContact()
    }

}
