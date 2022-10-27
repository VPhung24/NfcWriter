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
    var shareContact: CNContact?
    
    let shareContactButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 20
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        let defaults = UserDefaults.standard
        if let contact: CNContact = defaults.object(forKey: "contact") as? CNContact {
            shareContact = contact
            shareContactButton.setTitle("share contact", for: .normal)
        } else {
            shareContactButton.setTitle("create contact", for: .normal)
            shareContactButton.addTarget(self, action: #selector(createContact), for: .touchUpInside)
        }
        
        let modalBackgroundView = UIView(frame: .zero)
        modalBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        modalBackgroundView.backgroundColor = .systemBackground
        modalBackgroundView.layer.cornerRadius = 20
        
        self.view.addSubview(modalBackgroundView)
        
        modalBackgroundView.addSubview(shareContactButton)
        
        let gestureReconizer = UIPanGestureRecognizer(target: self, action: #selector(didPanOnView))
        
        self.view.addGestureRecognizer(gestureReconizer)
        
        NSLayoutConstraint.activate([
            modalBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            modalBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            modalBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            modalBackgroundView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 3),
            
            shareContactButton.centerXAnchor.constraint(equalTo: modalBackgroundView.centerXAnchor),
            shareContactButton.centerYAnchor.constraint(equalTo: modalBackgroundView.centerYAnchor),
        ])
        
    }
    
    @objc func didPanOnView(_ sender: UIPanGestureRecognizer) {
        DispatchQueue.main.async {
            // todo: delegate pop vc
        }
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
        self.shareContact = contact
        
        // todo: save contact
    }
}
