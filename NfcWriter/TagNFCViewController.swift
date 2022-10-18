//
//  TagNFCViewController.swift
//  NfcWriter
//
//  Created by Vivian Phung on 10/18/22.
//

import UIKit

class TagNFCViewController: UIViewController {
    let twitterProfile: TwitterHandleModel
    var profileImage: UIImage?
    
    let imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = twitterProfile.username
        navigationItem.backButtonTitle = "Back"
        
        APIManager.shared.getProfileImage(twitterHandleModel: twitterProfile, isFullImage: true) { [weak self] updatedTwitterModelWithImage, error in
            guard let updatedModel = updatedTwitterModelWithImage, let newImage = updatedModel.image else {
                return
            }
            self?.twitterProfile.image = newImage
            self?.profileImage = newImage
            DispatchQueue.main.async {
                self?.setProfilePhoto(withImage: newImage)
            }
        }
        
        setProfilePhoto(withImage: twitterProfile.image ?? UIImage(systemName: "star")!)
        
        self.view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -10),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
        ])
    }
    
    init(twitterProfile: TwitterHandleModel) {
        self.twitterProfile = twitterProfile
        self.profileImage = twitterProfile.image
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setProfilePhoto(withImage image: UIImage) {
        imageView.image = image
        imageView.setNeedsDisplay()
    }
}
