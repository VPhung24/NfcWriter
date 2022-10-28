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

    lazy var twitterButton = {
        let button = initButton(withStyle: .twitter)
        button.addTarget(self, action: #selector(twitterSelected), for: .touchUpInside)
        return button
    }()

    lazy var contactsButton = {
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
        let button = UIButton(frame: .zero)
        button.backgroundColor = style.backgroundColor()
        button.setTitle(style.title(), for: .normal)
        button.layer.cornerRadius = 20
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

enum NFCButtonStyle {
    case twitter
    case contacts

    func backgroundColor() -> UIColor {
        switch self {
        case .twitter:
            return .blue
        case .contacts:
            return .gray
        }
    }

    func title() -> String {
        switch self {
        case .twitter:
            return "twitter"
        case .contacts:
            return "contacts"
        }
    }
}

extension MainViewController: MyContactViewControllerDelegate {
    func dismissView() {
        self.dismiss(animated: true)
    }
}
