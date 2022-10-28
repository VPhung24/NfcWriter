//
//  MainViewController.swift
//  NfcWriter
//
//  Created by Vivian Phung on 10/27/22.
//

import UIKit

class MainViewController: UIViewController {

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

    @objc private func contactSelected() {
        let contactVC = MyContactViewController()
        contactVC.delegate = self
        self.presentNavController(withViewController: contactVC)
    }

    private func presentNavController(withViewController viewController: UIViewController) {
        DispatchQueue.main.async {
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.view.backgroundColor = .clear
            self.present(navigationController, animated: true)
        }
    }
}

enum NFCButtonStyle: String {
    case twitter
    case contacts

    func backgroundColor() -> UIColor {
        switch self {
        case .twitter:
            return UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1.0)
        case .contacts:
            return UIColor(red: 175/255, green: 135/255, blue: 74/255, alpha: 1.0)
        }
    }

    func image() -> UIImage {
        switch self {
        case .twitter:
            return UIImage(named: "twitter_white_logo")!.withRenderingMode(.alwaysOriginal)
        case .contacts:
            return UIImage(systemName: "person.crop.square.filled.and.at.rectangle.fill",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 300, weight: .bold, scale: .large))!.withTintColor(.white).withRenderingMode(.alwaysOriginal)
        }
    }
}

extension MainViewController: MyContactViewControllerDelegate {
    func dismissView() {
        self.dismiss(animated: true)
    }
}
