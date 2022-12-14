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
import CoreNFC
import VivUIExtensions

class MainViewController: UIViewController {
    var tagManager: NFCTagManager?
    var contact: CNContact? {
        UserDefaults.standard.contact(forKey: "contact")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        navigationItem.titleView = {
            let iphoneImageView = UIImageView(image: UIImage(systemName: "iphone")?.withTintColor(.label).withRenderingMode(.alwaysOriginal))
            iphoneImageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
            iphoneImageView.accessibilityLabel = "iphone"

            let waveImageView = UIImageView(image: UIImage(systemName: "wave.3.forward")?.withTintColor(.label).withRenderingMode(.alwaysOriginal))
            waveImageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
            waveImageView.accessibilityLabel = "writes nfcs"

            return UIStackView(arrangedSubViews: [iphoneImageView, waveImageView], axis: .horizontal)
        }()

        let buttonStackView = UIStackView(arrangedSubViews:
                                            [NFCAccessoryTypeButton(buttonType: .twitter, delegate: self),
                                             NFCAccessoryTypeButton(buttonType: .writeContact, delegate: self)],
                                          axis: .vertical,
                                          distribution: .fillEqually)

        view.addSubviewWithConstraints(buttonStackView, [
            buttonStackView.heightAnchor.constraint(equalToConstant: view.bounds.height / 3),
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonStackView.widthAnchor.constraint(equalToConstant: view.bounds.width - 20)
        ])
    }

    private func showCNContactViewController() {
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

    @objc private func dismissView() {
        self.dismiss(animated: true)
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
}

extension MainViewController: CNContactViewControllerDelegate {
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        guard let contact = contact else {
            self.dismiss(animated: true)
            return
        }

        uploadContact(contact)

        UserDefaults.standard.set(contact, forKey: "contact")

        self.dismiss(animated: true)
    }
}

extension MainViewController: NFCAccessoryTypeDelegate {
    func nfcButtonSelected(ofType: NFCAccessoryType) {
        switch ofType {
        case .twitter:
            DispatchQueue.main.async {
                self.present(UINavigationController(rootViewController: TwitterSearchViewController()), animated: true)
            }
        case .editContact:
            self.dismissView()
            showCNContactViewController()
        case .writeContact:
            if contact != nil {
                let contactViewController = ContactNFCTaggingViewController()
                contactViewController.delegate = self
                DispatchQueue.main.async {
                    self.present(contactViewController, animated: true)
                }
            } else {
                showCNContactViewController()
            }
        default:
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
    }

}
