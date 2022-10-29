//
//  MainViewController.swift
//  NfcWriter
//
//  Created by Vivian Phung on 10/27/22.
//

import UIKit
import ContactsUI
import Contacts
import ICU
import nanopb

class MainViewController: UIViewController {
    var contact: CNContact?
    var downloadURL: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "write nfc"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let twitterButton = UIButton(buttonStyle: .twitter)
        twitterButton.addTarget(self, action: #selector(twitterSelected), for: .touchUpInside)
        
        let contactsButton = UIButton(buttonStyle: .contacts)
        contactsButton.addTarget(self, action: #selector(contactSelected), for: .touchUpInside)
        
        let buttonStackView = UIStackView(frame: CGRect(x: 10, y: (view.bounds.height - 300) / 2, width: view.bounds.width - 20, height: 300), forAxis: .vertical)

        buttonStackView.addArrangedSubview(twitterButton)
        buttonStackView.addArrangedSubview(contactsButton)

        self.view.addSubview(buttonStackView)
    }
    
    @objc private func twitterSelected() {
        self.presentNavController(withViewController: SearchViewController())
    }

    private func showContactViewController() {
        let contactViewController = (self.contact != nil) ? CNContactViewController(for: self.contact!) : CNContactViewController(forNewContact: nil)
        contactViewController.delegate = self
        contactViewController.allowsActions = false

        // CNContactViewController(forNewContact: pushes onto a white host vc. looks weird lets make it clear
        let contactNavigationController = UINavigationController(rootViewController: contactViewController)
        let contactHostViewController = contactNavigationController.viewControllers.first
        contactHostViewController?.view.backgroundColor = .clear
        contactHostViewController?.navigationController?.setNavigationBarHidden(true, animated: false)

        DispatchQueue.main.async {
            self.present(contactNavigationController, animated: false)
            contactNavigationController.setNavigationBarHidden(false, animated: false)
            if self.contact != nil {
                contactViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.dismissView))
            }
        }
    }

    @objc private func contactSelected() {
        if self.contact ?? UserDefaults.standard.contact(forKey: "contact") != nil {
            let contactViewController = MyContactViewController()
            contactViewController.delegate = self
            self.presentNavController(withViewController: contactViewController)
        } else {
            showContactViewController()
        }
    }

    private func presentNavController(withViewController viewController: UIViewController) {
        DispatchQueue.main.async {
            let navigationController = UINavigationController(rootViewController: viewController)
            self.present(navigationController, animated: true)
        }
    }

    private func uploadContact(_ contact: CNContact) {
        do {
            let data: Data = try CNContactVCardSerialization.data(with: [contact])

            let fileRef = storageRef.child("contacts/\(UIDevice.current.identifierForVendor!.uuidString).vcf")

            fileRef.putData(data, metadata: nil) { (metadata, error) in
                guard metadata != nil else {
                    print(error ?? "error")
                    return
                }

                fileRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        print(error ?? "error")
                        return
                    }
                    self.downloadURL = downloadURL.absoluteString
                    print(downloadURL)
                }
            }
        } catch {
            print("error uploading contact")
        }
    }
}

extension MainViewController: MyContactViewControllerDelegate {
    @objc func dismissView() {
        self.dismiss(animated: true)
    }

    func editContact() {
        self.dismiss(animated: true)
        showContactViewController()
    }
}

extension MainViewController: CNContactViewControllerDelegate {
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        guard let contact = contact else {
            self.dismiss(animated: true)
            return
        }

        uploadContact(contact)

        self.contact = contact

        UserDefaults.standard.setContact(contact, forKey: "contact")

        self.dismiss(animated: true) {
            self.contactSelected()
        }
    }
}
