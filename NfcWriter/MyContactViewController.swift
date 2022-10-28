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
}

class MyContactViewController: UIViewController {
    var shareContact: CNContact?
    var contactVC: CNContactViewController?
    weak var delegate: MyContactViewControllerDelegate?
    
    let shareContactButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        button.setTitleColor(.secondaryLabel, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if DEBUG
            print("debug")
            UserDefaults.standard.removeObject(forKey: "contact")
        #else
            print("prod")
        #endif
        view.backgroundColor = .clear
        
        setupContactSharing()
        
        let modalBackgroundView: UIView = {
            let view = UIView(frame: .zero)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .systemBackground
            view.layer.cornerRadius = 20
            return view
        }()
        
        self.view.addSubview(modalBackgroundView)
        modalBackgroundView.addSubview(shareContactButton)
        
        NSLayoutConstraint.activate([
            modalBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            modalBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            modalBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            modalBackgroundView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 3),
            
            shareContactButton.centerXAnchor.constraint(equalTo: modalBackgroundView.centerXAnchor),
            shareContactButton.centerYAnchor.constraint(equalTo: modalBackgroundView.centerYAnchor),
        ])
    }
    
    private func setupContactSharing() {
        if let contact: CNContact = shareContact ?? UserDefaults.standard.contact(forKey: "contact") {
            shareContact = contact
            shareContactButton.removeTarget(self, action: #selector(createContact), for: .touchUpInside)
            shareContactButton.setTitle("share contact", for: .normal)
            shareContactButton.addTarget(self, action: #selector(shareNfcContact), for: .touchUpInside)
        } else {
            shareContactButton.setTitle("create contact", for: .normal)
            shareContactButton.addTarget(self, action: #selector(createContact), for: .touchUpInside)
        }
    }
    
    @objc func shareNfcContact() {
        print("nfc writing here")
    }
    
    @objc func createContact() {
        print("create contact")
        // todo: add animation to full screen white and then push
        
        contactVC = contactVC ?? CNContactViewController(forNewContact: nil)
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(self.contactVC!, animated: true)
        }
        contactVC?.delegate = self
    }
}

extension MyContactViewController: CNContactViewControllerDelegate {
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        self.navigationController?.popViewController(animated: true)
        guard let contact = contact else { return }
        self.shareContact = contact
        
        UserDefaults.standard.setContact(contact, forKey: "contact")
        
        setupContactSharing()
    }
}
