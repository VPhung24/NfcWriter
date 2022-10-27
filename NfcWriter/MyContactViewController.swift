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
    weak var delegate: MyContactViewControllerDelegate?
    
    let shareContactButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 20
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if DEBUG
            print("App is in Debug mode")
            UserDefaults.standard.removeObject(forKey: "contact")
        #else
            print("App is in production mode")
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
        
        modalBackgroundView.addSubview(shareContactButton)
        self.view.addSubview(modalBackgroundView)
        self.view.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(didGesture)))
        
        NSLayoutConstraint.activate([
            modalBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            modalBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            modalBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            modalBackgroundView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 3),
            
            shareContactButton.centerXAnchor.constraint(equalTo: modalBackgroundView.centerXAnchor),
            shareContactButton.centerYAnchor.constraint(equalTo: modalBackgroundView.centerYAnchor),
        ])
        
    }
    
    fileprivate func setupContactSharing() {
        if let contact: CNContact = UserDefaults.standard.contact(forKey: "contact") {
            shareContact = contact
            shareContactButton.setTitle("share contact", for: .normal)
            shareContactButton.addTarget(self, action: #selector(shareNfcContact), for: .touchUpInside)
        } else {
            shareContactButton.setTitle("create contact", for: .normal)
            shareContactButton.addTarget(self, action: #selector(createContact), for: .touchUpInside)
        }
    }
    
    @objc func didGesture(_ sender: UIGestureRecognizer) {
        DispatchQueue.main.async {
            self.delegate?.dismissView()
        }
    }
    
    @objc func shareNfcContact() {
        print("nfc writing here")
    }
    
    @objc func createContact() {
        // todo: add animation to full screen white and then push
        let contact = CNContactViewController(forNewContact: nil)
        self.navigationController?.pushViewController(contact, animated: true)
        contact.delegate = self
    }
}

extension MyContactViewController: CNContactViewControllerDelegate {
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        guard let contact = contact else { return }
        self.shareContact = contact
        
        UserDefaults.standard.setContact(contact, forKey: "contact")
        
        setupContactSharing()
    }
}
