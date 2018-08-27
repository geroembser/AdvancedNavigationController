//
//  AdvancedNavigationController.swift
//  AdvancedNavigationController iOS
//
//  Created by Gero Embser on 19.08.18.
//  Copyright © 2018 Gero Embser. All rights reserved.
//

import UIKit

open class AdvancedNavigationController: UINavigationController {
    //MARK: - view lifecycle
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        //the NavigationControllerDelegate is always the controller itself, outside usable delegates are "shadowed"
        super.delegate = self
    }
    
    //MARK: - shadow delegate
    private weak var shadowDelegate: UINavigationControllerDelegate?
    override open var delegate: UINavigationControllerDelegate? {
        set {
            shadowDelegate = newValue
        }
        get {
            //use the call stack to determine whether the delegate was queried by the superclass or any other class
            //it is important to return the non shadow delegate if called from the superclass, because only this way, we ensure that the superclass implementation calls all the delegate methods in this class so that this class can forward the messages
            //that's how properties in a class hierarchie work in objc
            
            
            let relevantSymbol = Thread.callStackSymbols[2] //the third symbol is the relevant, because it is the caller of the delegate-accessor (the first two symbols are other methods which I think are related to Swift/objc conversion with properties etc.)
            
            let condensedSymbol = relevantSymbol.condenseWhitespace() //no whitespaces, so we can query data more structured in the string
            
            let components = condensedSymbol.components(separatedBy: " ")
            
            //make sure it has more than 5 components
            guard components.count >= 6 else {
                //return the shadow delegate
                return shadowDelegate
            }
            
            //get the class that called this method/variable (only works in debugging mode)
            //let callingClassName = components[3].replacingOccurrences(of: "-[", with: "")
            
            //get the framework where the call was originated from
            let framework = components[1]
            
            //if the framework is "UIKitCore, the call's origin is UIKit, so return the actual delegate on which UIKit relies – not the shadow delegate
            guard framework != "UIKitCore" else {
                //actual/internal delegate
                return super.delegate
            }
            
            //the call is not from UIKitCore, so we return the shadow delegate
            return shadowDelegate
        }
    }
    
    //MARK: - notifications
    private var handlers: [NavigationControllerEventHandler] = []
    private var didShowEventHandlers: [NavigationControllerEventHandler] {
        return handlers.filter { $0.kind == .didShow }
    }
    private var willShowEventHandlers: [NavigationControllerEventHandler] {
        return handlers.filter { $0.kind == .willShow }
    }
    private var willPushEventHandlers: [NavigationControllerEventHandler] {
        return handlers.filter { $0.kind == .willPush }
    }
    private var didPushEventHandlers: [NavigationControllerEventHandler] {
        return handlers.filter { $0.kind == .didPush }
    }
    private var willPopEventHandlers: [NavigationControllerEventHandler] {
        return handlers.filter { $0.kind == .willPop }
    }
    private var didPopEventHandlers: [NavigationControllerEventHandler] {
        return handlers.filter { $0.kind == .didPop }
    }
    
    ///Calls all the handlers in the given array for/with the given ViewController
    private func call(eventHandlers: [NavigationControllerEventHandler],
                      forViewController viewController: UIViewController) {
        eventHandlers.forEach { $0.action(viewController) }
    }
    
    
    ///The return handler can be discarded, if it isn't planned to remove the handler before the deinitialization of the AdvancedNavigationController.
    ///As long as the AdvancedNavigationController exists, an added handler is called for the appropriate events. If the AdvancedNavigationController is about to be removed from memory (because no one uses the AdvancedNavigationController), usually all handlers are also freed (if the handler themselves don't refer to the AdvancedNavigationController instance).
    open func add(didShowEventAction action: @escaping NavigationControllerEventHandler.Action) -> NavigationControllerEventHandler {
        return add(handlerFor: .didShow, withAction: action)
    }
    open func add(willShowEventAction action: @escaping NavigationControllerEventHandler.Action) -> NavigationControllerEventHandler {
        return add(handlerFor: .willShow, withAction: action)
    }
    
    open func add(didPushEventAction action: @escaping NavigationControllerEventHandler.Action) -> NavigationControllerEventHandler {
        return add(handlerFor: .didPush, withAction: action)
    }
    open func add(willPushEventAction action: @escaping NavigationControllerEventHandler.Action) -> NavigationControllerEventHandler {
        return add(handlerFor: .willPush, withAction: action)
    }
    
    open func add(didPopEventAction action: @escaping NavigationControllerEventHandler.Action) -> NavigationControllerEventHandler {
        return add(handlerFor: .didPop, withAction: action)
    }
    open func add(willPopEventAction action: @escaping NavigationControllerEventHandler.Action) -> NavigationControllerEventHandler {
        return add(handlerFor: .willPop, withAction: action)
    }
    
    open func add(handlerFor kind: NavigationControllerEventHandler.Kind,
                    withAction action: @escaping NavigationControllerEventHandler.Action) -> NavigationControllerEventHandler {
        //create new handler
        let handler = NavigationControllerEventHandler(action: action, kind: kind)
        
        //add it...
        add(eventHandler: handler)
        
        return handler
    }
    
    private func add(eventHandler handler: NavigationControllerEventHandler) {
        handlers += [handler]
    }
    open func remove(eventHandler handler: NavigationControllerEventHandler) {
        handlers.removeAll { $0 === handler }
    }
    open func remove(eventHandlers: [NavigationControllerEventHandler]) {
        eventHandlers.forEach { self.remove(eventHandler: $0) }
    }
    
    //MARK: - recognizing push/pop
    ///Stores the last value of the viewControllers variable, to be able to recognize push-and pops appropriately
    ///It is, of course, initially empty
    private var lastViewControllersValue: [UIViewController] = []
    
    ///Updates the value of the lastViewControllersValue-variable
    private func updateLastViewControllersValue() {
        lastViewControllersValue = self.viewControllers
    }
}

extension AdvancedNavigationController: UINavigationControllerDelegate {
    //MARK: showing
    public func navigationController(_ navigationController: UINavigationController,
                                     didShow viewController: UIViewController, animated: Bool) {
        //call the actions (which don't need further investigation
        call(eventHandlers: didShowEventHandlers, forViewController: viewController)
        
        //determine whether push or pop was completed
        if viewControllers.count > lastViewControllersValue.count {
            //push
            call(eventHandlers: didPushEventHandlers, forViewController: viewController)
        }
        else if viewControllers.count < lastViewControllersValue.count {
            //pop
            call(eventHandlers: didPopEventHandlers, forViewController: viewController)
        }
        //otherwise nothing
        
        //update lastViewControllersValue at the end!!!
        updateLastViewControllersValue()
    }
    public func navigationController(_ navigationController: UINavigationController,
                                     willShow viewController: UIViewController, animated: Bool) {
        //call the actions
        call(eventHandlers: willShowEventHandlers, forViewController: viewController)
        
        //determine whether push or pop began
        if viewControllers.count > lastViewControllersValue.count {
            //push
            call(eventHandlers: willPushEventHandlers, forViewController: viewController)
        }
        else if viewControllers.count < lastViewControllersValue.count {
            //pop
            call(eventHandlers: willPopEventHandlers, forViewController: viewController)
        }
        //otherwise nothing
        //Don't update the lastViewControllersValue until it isn't completed (which can only be assumed in the didShow... method above)
    }
    
    //MARK: transitions
    public func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return shadowDelegate?.navigationController?(navigationController,
                                                     animationControllerFor: operation,
                                                     from: fromVC,
                                                     to: toVC)
    }
    public func navigationController(_ navigationController: UINavigationController,
                              interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return shadowDelegate?.navigationController?(navigationController,
                                                     interactionControllerFor: animationController)
    }
    public func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation {
        return shadowDelegate!.navigationControllerPreferredInterfaceOrientationForPresentation!(navigationController)
    }
    public func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return shadowDelegate!.navigationControllerSupportedInterfaceOrientations!(navigationController)
    }
}

//MARK: - selector responds
extension AdvancedNavigationController {
    override open func responds(to aSelector: Selector!) -> Bool {
        let transitionSelectors = [#selector(navigationController(_:animationControllerFor:from:to:)),
                                   #selector(navigationController(_:interactionControllerFor:)),
                                   #selector(navigationControllerPreferredInterfaceOrientationForPresentation(_:)),
                                   #selector(navigationControllerSupportedInterfaceOrientations(_:))]
        
        if transitionSelectors.contains(aSelector) {
            return shadowDelegate?.responds(to:aSelector) ?? false
        }
        
        return super.responds(to: aSelector)
    }
}


//MARK: - event handling
open class NavigationControllerEventHandler {
    public enum Kind {
        case didShow
        case willShow
        case willPush
        case didPush
        case willPop
        case didPop
    }
    public let kind: Kind
    
    public typealias Action = (UIViewController) -> Void
    public let action: Action
    
    public init(action: @escaping Action, kind: Kind) {
        self.action = action
        self.kind = kind
    }
}
