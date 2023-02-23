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
import VivUIKitExtensions

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

        let twitterButton: UIButton = UIButton.nfcAccessor(type: .twitter, primaryAction: UIAction(handler: { [weak self] (_) in
            self?.nfcButtonSelected(type: .twitter)
        }))
        let contactButton: UIButton = UIButton.nfcAccessor(type: .writeContact, primaryAction: UIAction(handler: { [weak self] (_) in
            self?.nfcButtonSelected(type: .writeContact)
        }))

        let buttonStackView = UIStackView(arrangedSubViews: [twitterButton, contactButton],
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
        let newContact: Bool = contact == nil
        let contactViewController = newContact ?  CNContactViewController(forNewContact: nil) : CNContactViewController(for: contact!)
        contactViewController.view.backgroundColor = .clear
        contactViewController.delegate = self
        contactViewController.allowsActions = false
        contactViewController.view.layoutIfNeeded()

        let navigationController = UINavigationController(rootViewController: contactViewController)
        navigationController.isNavigationBarHidden = true
        DispatchQueue.main.async {
            self.present(navigationController, animated: false) {
                navigationController.isNavigationBarHidden = false
                if !newContact {
                    navigationController.topViewController?.navigationItem.setLeftBarButton( UIBarButtonItem(systemItem: .cancel, primaryAction: UIAction { [weak self] _ in
                        self?.dismiss(animated: true)
                    }), animated: false)

                }
            }
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

    private func dismissVC(animated: Bool) {
        DispatchQueue.main.async {
            self.dismiss(animated: animated)
        }
    }
}

extension MainViewController: CNContactViewControllerDelegate {
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        guard let contact = contact else {
            self.dismissVC(animated: true)
            return
        }

        uploadContact(contact)

        UserDefaults.standard.set(contact, forKey: "contact")

        self.dismissVC(animated: true)

    }
}

extension MainViewController: NFCAccessoryTypeDelegate {

    func nfcButtonSelected(type: NFCAccessoryType) {
        switch type {
        case .twitter:
            DispatchQueue.main.async {
                self.present(UINavigationController(rootViewController: TwitterSearchViewController()), animated: true)
            }
        case .editContact:
            DispatchQueue.main.async {
                self.dismiss(animated: true) {
                    self.showCNContactViewController()
                }
            }
        case .writeContact:
            DispatchQueue.main.async {
                self.showCNContactViewController()
            }
        case .dismiss:
            self.dismissVC(animated: true)
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
