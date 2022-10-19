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
    
    var readerSession: NFCNDEFReaderSession?
    var ndefMessage: NFCNDEFMessage?
    
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

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "write", style: .plain, target: self, action: #selector(writeTag))
        
        APIManager.shared.getProfileImage(twitterHandleModel: twitterProfile, isFullImage: true) { [weak self] updatedTwitterModelWithImage, error in
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
        
        readerSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        readerSession?.alertMessage = "Hold your iPhone near a writable NFC tag to update."
        readerSession?.begin()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.popViewController(animated: false)
    }
    
    private func createURLPayload() -> NFCNDEFPayload? {
        let twitterURL = URL(string: "https://twitter.com/\(twitterProfile.username)")
        
        os_log("url: %@", (twitterURL?.absoluteString)!)
        
        return NFCNDEFPayload.wellKnownTypeURIPayload(url: (twitterURL?.absoluteURL)!)
    }
}

extension TagNFCViewController: NFCNDEFReaderSessionDelegate {
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        
    }
    
    func tagRemovalDetect(_ tag: NFCNDEFTag) {
        // In the tag removal procedure, you connect to the tag and query for
        // its availability. You restart RF polling when the tag becomes
        // unavailable; otherwise, wait for certain period of time and repeat
        // availability checking.
        self.readerSession?.connect(to: tag) { (error: Error?) in
            if error != nil || !tag.isAvailable {
                
                os_log("Restart polling")
                
                self.readerSession?.restartPolling()
                return
            }
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + .milliseconds(500), execute: {
                self.tagRemovalDetect(tag)
            })
        }
    }
    
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        let textPayload = NFCNDEFPayload.wellKnownTypeTextPayload(
            string: "Twitter Tag",
            locale: Locale(identifier: "En")
        )
        let urlPayload = self.createURLPayload()
        ndefMessage = NFCNDEFMessage(records: [urlPayload!, textPayload!])
        os_log("MessageSize=%d", ndefMessage!.length)
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        if tags.count > 1 {
            session.alertMessage = "More than 1 tags found. Please present only 1 tag."
            self.tagRemovalDetect(tags.first!)
            return
        }
        
        // You connect to the desired tag.
        let tag = tags.first!
        session.connect(to: tag) { (error: Error?) in
            if error != nil {
                session.restartPolling()
                return
            }
            
            // You then query the NDEF status of tag.
            tag.queryNDEFStatus() { (status: NFCNDEFStatus, capacity: Int, error: Error?) in
                if error != nil {
                    session.invalidate(errorMessage: "Fail to determine NDEF status.  Please try again.")
                    return
                }
                
                if status == .readOnly {
                    session.invalidate(errorMessage: "Tag is not writable.")
                } else if status == .readWrite {
                    if self.ndefMessage!.length > capacity {
                        session.invalidate(errorMessage: "Tag capacity is too small.  Minimum size requirement is \(self.ndefMessage!.length) bytes.")
                        return
                    }
                    
                    // When a tag is read-writable and has sufficient capacity,
                    // write an NDEF message to it.
                    tag.writeNDEF(self.ndefMessage!) { (error: Error?) in
                        if error != nil {
                            session.invalidate(errorMessage: "Update tag failed. Please try again.")
                        } else {
                            session.alertMessage = "Update success!"
                            session.invalidate()
                        }
                    }
                } else {
                    session.invalidate(errorMessage: "Tag is not NDEF formatted.")
                }
            }
        }
    }
}
