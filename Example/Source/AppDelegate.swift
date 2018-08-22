//
//  AppDelegate.swift
//  AdvancedNavigationController Example
//
//  Created by Gero Embser on 19.08.18.
//  Copyright © 2018 Gero Embser. All rights reserved.
//

import UIKit
import AdvancedNavigationController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //perform advanced navigation controller setup
        setupNavigationController()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate {
    private func setupNavigationController() {
        guard let advancedNavigationController = self.window?.rootViewController as? AdvancedNavigationController else {
            //nothing to do... (anything went wrong...)
            fatalError("This example App expects to have an AdvancedNavigationController instance as the rootViewController!")
        }
        
        //we discard the result, because it should exist as long as the app is running
        _ = advancedNavigationController.add(didShowEventAction: { (showedViewController) in
            guard let hello = (showedViewController as? HelloViewController)?.hello else {
                return //don't notifiy
            }
            
            self.showOverlay(withMessage: "Did say \(hello)")
            print("showed: \(hello) using \(showedViewController)")
        })
        _ = advancedNavigationController.add(willShowEventAction: { (showingViewController) in
            guard let hello = (showingViewController as? HelloViewController)?.hello else {
                return //don't notifiy
            }
            
            self.showOverlay(withMessage: "Will say \(hello)")
            print("will show: \(hello) using \(showingViewController)")
        })
    }
}

//MARK: - overlay
extension AppDelegate {
    private func showOverlay(withMessage message: String) {
        guard let window = window else {
            return //no view that can show the window
        }
        let container = UIView()
        container.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.4
        container.layer.shadowOffset = CGSize.zero
        container.layer.shadowRadius = 2
        
        container.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(container)
        
        let height = 70
        let containerConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[container]-0-|",
                                                         options: [],
                                                         metrics: nil,
                                                         views: ["container": container])
            + NSLayoutConstraint.constraints(withVisualFormat: "V:[container(==\(height))]",
                                             options: [],
                                             metrics: nil,
                                             views: ["container": container])
        let bottomSpacingConstraint = NSLayoutConstraint(item: container,
                                                         attribute: .bottom,
                                                         relatedBy: .equal,
                                                         toItem: container.superview!,
                                                         attribute: .bottom,
                                                         multiplier: 1.0,
                                                         constant: CGFloat(height))
        NSLayoutConstraint.activate(containerConstraints + [bottomSpacingConstraint])
        
        let label = UILabel()
        label.text = message
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        
        let labelConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[label]-8-|",
                                                              options: [],
                                                              metrics: nil,
                                                              views: ["label": label])
            + NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[label]-8-|",
                                             options: [],
                                             metrics: nil, views: ["label": label])
        NSLayoutConstraint.activate(labelConstraints)
        
        //show the overlay
        window.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            bottomSpacingConstraint.constant = 0
            window.layoutIfNeeded()
        }) { (completed) in
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (timer) in
                window.layoutIfNeeded()
                UIView.animate(withDuration: 0.2, animations: {
                    bottomSpacingConstraint.constant = CGFloat(height)
                    window.layoutIfNeeded()
                }, completion: { (_) in
                    container.removeFromSuperview()
                })
            })
        }
        
    }
}

