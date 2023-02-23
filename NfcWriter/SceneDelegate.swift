//
//  SceneDelegate.swift
//  NfcWriter
//
//  Created by Vivian Phung on 10/17/22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        window.makeKeyAndVisible()

        #if DEBUG
            print("testing ===> remove contact user default")
            UserDefaults.standard.removeObject(forKey: "contact")
        #endif

        let rootViewController = UINavigationController(rootViewController: MainViewController())

        window.rootViewController = rootViewController
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}
}
