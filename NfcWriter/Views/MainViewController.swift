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

    lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(frame: CGRect(x: 10, y: (view.bounds.height - 300) / 2, width: view.bounds.width - 20, height: 300))
        stackView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin]
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 20
        return stackView
    }()

    lazy var twitterButton: UIButton = {
        let button = initButton(withStyle: .twitter)
        button.addTarget(self, action: #selector(twitterSelected), for: .touchUpInside)
        return button
    }()

    lazy var contactsButton: UIButton = {
        let button = initButton(withStyle: .contacts)
        button.addTarget(self, action: #selector(contactSelected), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // #if DEBUG
        //        print("debug")
        //        UserDefaults.standard.removeObject(forKey: "contact")
        // #else
        //        print("prod")
        // #endif

        title = "write nfc"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        buttonStackView.addArrangedSubview(twitterButton)
        buttonStackView.addArrangedSubview(contactsButton)

        self.view.addSubview(buttonStackView)
    }

    private func initButton(withStyle style: NFCButtonStyle) -> UIButton {
        let button = UIButton(type: .roundedRect)
        button.backgroundColor = style.backgroundColor()
        button.layer.cornerRadius = 20
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .left
        button.imageEdgeInsets = UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
        button.setImage(style.image(), for: .normal)
        return button
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
