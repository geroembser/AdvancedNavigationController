//
//  ViewController.swift
//  AdvancedNavigationController Example
//
//  Created by Gero Embser on 19.08.18.
//  Copyright © 2018 Gero Embser. All rights reserved.
//

import UIKit

class HelloViewController: UIViewController {
    //MARK: - instance variables
    var hello: String = "Miau"
    var face: String = "🐈"
    
    //MARK: - view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //make sure the next-button is showed/hidden appropriately
        showHideNextButtonAppropriately()
        
        //setup ui
        setupUI()
    }
    private func showHideNextButtonAppropriately() {
        if canShowNextHello {
            nextButton.isHidden = false
        }
        else {
            nextButton.isHidden = true
        }
    }
    private func setupUI() {
        self.navigationItem.title = hello
        self.faceLabel.text = face
    }
    
    //MARK: - outlets
    @IBOutlet var faceLabel: UILabel!
    @IBOutlet var nextButton: UIButton!
    
    //MARK: - actions
    ///The action called if the user taps on the next-button
    @IBAction func next(_ sender: UIButton) {
        guard let nextHello = nextHello else {
            return //can't go to the next step
        }
        
        //find a random face!!!
        let nextFace = Contents.faces.randomElement() ?? "🐈" //cats are always fine...
        
        //create a new HelloViewController and push it on the NavigationController
        let newHelloViewController = HelloViewController.say(hello: nextHello, withFace: nextFace)
        self.navigationController?.pushViewController(newHelloViewController, animated: true)
    }
}

//MARK: - helpers
extension HelloViewController {
    private var nextHello: String? {
        let currentHelloIndex = Contents.hello.firstIndex(of: hello) ?? -1 //otherwise start at the beginning
        
        return Contents.hello[safe: currentHelloIndex+1]
        
    }
    private var canShowNextHello: Bool {
        return nextHello != nil
    }
}

//MARK: - creation
extension HelloViewController {
    class func say(hello: String, withFace face: String) -> HelloViewController {
        let helloViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HelloViewController") as! HelloViewController
        
        helloViewController.hello = hello
        helloViewController.face = face
        
        return helloViewController
    }
}

