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
import VivUIExtensions

class MainViewController: UIViewController {
    var contact: CNContact? {
        UserDefaults.standard.contact(forKey: "contact")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        navigationItem.titleView = initTitleLabel()

        let twitterButton = UIButton(buttonStyle: .twitter)
        twitterButton.addTarget(self, action: #selector(twitterSelected), for: .touchUpInside)
        twitterButton.accessibilityLabel = NFCButtonStyle.twitter.accessibilityLabel
        twitterButton.accessibilityHint = NFCButtonStyle.twitter.accessibilityHint

        let contactsButton = UIButton(buttonStyle: .contacts)
        contactsButton.addTarget(self, action: #selector(contactSelected), for: .touchUpInside)
        contactsButton.accessibilityLabel = NFCButtonStyle.contacts.accessibilityLabel
        contactsButton.accessibilityHint = NFCButtonStyle.contacts.accessibilityHint

        let buttonStackView = UIStackView(arrangedSubViews: [twitterButton, contactsButton], axis: .vertical, distribution: .fillEqually)

        view.addSubviewWithConstraints(buttonStackView, [
            buttonStackView.heightAnchor.constraint(equalToConstant: view.bounds.height / 3),
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonStackView.widthAnchor.constraint(equalToConstant: view.bounds.width - 20)
        ])
    }

    @objc private func twitterSelected() {
        self.presentNavController(withViewController: SearchViewController())
    }

    private func showContactViewController() {
        let contactViewController = (contact != nil) ? CNContactViewController(for: contact!) : CNContactViewController(forNewContact: nil)
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
        if contact != nil {
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
                    guard url != nil else {
                        // Uh-oh, an error occurred!
                        print(error ?? "error getting url")
                        return
                    }
                    print("download successful")
                }
            }
        } catch {
            print("error uploading contact")
        }
    }

    private func initTitleLabel() -> UIView {
        let iphoneImageView = UIImageView(image: UIImage(systemName: "iphone")?.withTintColor(.label).withRenderingMode(.alwaysOriginal))
        iphoneImageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
        iphoneImageView.accessibilityLabel = "iphone"

        let waveImageView = UIImageView(image: UIImage(systemName: "wave.3.forward")?.withTintColor(.label).withRenderingMode(.alwaysOriginal))
        waveImageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
        waveImageView.accessibilityLabel = "writes nfcs"

        return UIStackView(arrangedSubViews: [iphoneImageView, waveImageView], axis: .horizontal)
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

        UserDefaults.standard.set(contact, forKey: "contact")

        self.dismiss(animated: true) {
            self.contactSelected()
        }
    }
}
