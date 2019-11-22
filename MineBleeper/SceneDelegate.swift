//
//  SceneDelegate.swift
//  MineBleeper
//
//  Created by Wikipedia Brown on 11/7/19.
//  Copyright © 2019 IamGoodBad. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = RootViewController()
        window?.makeKeyAndVisible()
    }
}

//func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//    // Override point for customization after application launch.
//    imageArr = ["1.jpeg","2.jpeg","3.jpeg","4.jpeg"]
//
//    let RandomNumber = Int(arc4random_uniform(UInt32(self.imageArr.count)))
//    //imageArr is array of images
//     let image = UIImage.init(named: "\(imageArr[RandomNumber])")
//
//    let imageView = UIImageView.init(image: image)
//    imageView.frame = UIScreen.main.bounds
//
//    window = UIWindow(frame: UIScreen.main.bounds)
//    window?.rootViewController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
//    window?.rootViewController?.view.addSubview(imageView)
//    window?.rootViewController?.view.bringSubview(toFront: imageView)
//    window?.makeKeyAndVisible()
//
//    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
//        self.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
//    }
//    return true
//}
