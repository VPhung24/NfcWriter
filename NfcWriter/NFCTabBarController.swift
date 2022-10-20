//
//  NFCTabBarController.swift
//  NfcWriter
//
//  Created by Vivian Phung on 10/19/22.
//

import UIKit

class NFCTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchViewController = configTabFor(viewController: SearchViewController(), withSystemImageName: "magnifyingglass")
        let tagNFCViewController = configTabFor(viewController: RewriteViewController(), withSystemImageName: "pencil")

        viewControllers = [searchViewController, tagNFCViewController]
        selectedIndex = 0
        view.tintColor = .white
    }
    
    private func configTabFor(viewController: UIViewController, withSystemImageName imageName: String) -> UIViewController {
        let vc = UINavigationController(rootViewController: viewController)
        vc.tabBarItem.image = UIImage(systemName: imageName)
        vc.tabBarController?.tabBar.backgroundColor = .clear
        vc.tabBarItem.badgeColor = .clear
        return vc
    }
}
