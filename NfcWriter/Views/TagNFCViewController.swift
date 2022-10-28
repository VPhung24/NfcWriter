//
//  TagNFCViewController.swift
//  NfcWriter
//
//  Created by Vivian Phung on 10/18/22.
//

import UIKit
import CoreNFC
import os

class TagNFCViewController: UIViewController {
    let twitterProfile: TwitterHandleModel

    var tagManager: NFCTagManager?

    let imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = false
        imageView.layer.cornerRadius = (UIScreen.main.bounds.width - 20) / 2
        imageView.clipsToBounds = true
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = twitterProfile.username
        view.backgroundColor = .systemBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "write", style: .plain, target: self, action: #selector(writeTag))

        APIManager.shared.getProfileImage(twitterHandleModel: twitterProfile, isFullImage: true) { [weak self] updatedTwitterModelWithImage, _ in
            guard let updatedModel = updatedTwitterModelWithImage, let newImage = updatedModel.image else {
                return
            }
            self?.twitterProfile.image = newImage
            DispatchQueue.main.async {
                self?.setProfilePhoto(withImage: newImage)
            }
        }

        setProfilePhoto(withImage: twitterProfile.image ?? UIImage(systemName: "star")!)

        self.view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            imageView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 20)
        ])
    }

    init(twitterProfile: TwitterHandleModel) {
        self.twitterProfile = twitterProfile

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setProfilePhoto(withImage image: UIImage) {
        imageView.image = image
        imageView.setNeedsDisplay()
    }

    // MARK: - Actions
    @objc func writeTag() {
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

        tagManager = NFCTagManager(url: "https://twitter.com/\(twitterProfile.username)")
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

}
