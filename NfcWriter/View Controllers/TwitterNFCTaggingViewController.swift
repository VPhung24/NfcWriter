//
//  TwitterNFCTaggingViewController.swift
//  NfcWriter
//
//  Created by Vivian Phung on 10/18/22.
//

import UIKit
import CoreNFC
import VivUIKitExtensions
import VivNetworkExtensions

class TwitterNFCTaggingViewController: UIViewController {
    let twitterProfile: TwitterProfileModel
    var tagManager: NFCTagManager?

    private lazy var imageView = UIImageView().configured {
        $0.contentMode = .scaleAspectFit
        $0.layer.masksToBounds = false
        $0.layer.cornerRadius = (UIScreen.main.bounds.width - 20) / 2
        $0.clipsToBounds = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = twitterProfile.username
        view.backgroundColor = .systemBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "write", style: .plain, target: self, action: #selector(writeTag))

        APIManager.shared.getProfileImage(twitterHandleModel: twitterProfile, isFullImage: true) { [weak self] (updatedTwitterModelWithImage, imageError: Error?) in
            guard let newImage = updatedTwitterModelWithImage?.image, imageError == nil else {
                imageError.customPrintMessage("retrieving twitter profile full image")
                return
            }
            self?.twitterProfile.image = newImage
            DispatchQueue.main.async {
                self?.setProfilePhoto(withImage: newImage)
            }
        }

        setProfilePhoto(withImage: twitterProfile.image ?? UIImage(systemName: "star")!)

        self.view.addSubviewWithInsets(imageView)
    }

    init(twitterProfile: TwitterProfileModel) {
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
            print("error reading nfc ====> !NFCNDEFReaderSession.readingAvailable")
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
        super.viewWillDisappear(animated)
    }
}

extension Error? {
    func customPrintMessage(_ description: String = "") {
        print("error \(description) ====> \((self != nil) ? self!.localizedDescription : "")")
    }
}
