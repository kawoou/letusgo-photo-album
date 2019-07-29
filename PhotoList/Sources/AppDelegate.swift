//
//  AppDelegate.swift
//  PhotoList
//
//  Created by Kawoou on 29/07/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = {
            let window = UIWindow()
            window.rootViewController = UINavigationController(
                rootViewController: ListViewController()
            )
            window.makeKeyAndVisible()
            return window
        }()

        return true
    }
}

