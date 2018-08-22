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
    private var shadowDelegate: UINavigationControllerDelegate?
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
            
            //make sure it has exactly 7 components
            guard components.count == 7 else {
                //return the shadow delegate
                return shadowDelegate
            }
            
            //get the class that called this method/variable
            let callingClassName = components[3].replacingOccurrences(of: "-[", with: "")
            
            //make sure the class name exists
            guard let aClass = NSClassFromString(callingClassName) else {
                //shadow delegate...
                return shadowDelegate
            }
            
            //make sure the class is UINavigationController
            guard aClass == UINavigationController.self else {
                //shadow delegate
                return shadowDelegate
            }
            
            //if delegate is called form UINavigationController (aka called from the superclass), return the non-shadow delegate
            return super.delegate
        }
    }
    
    //MARK: - notifications
    private var handlers: [EventHandler] = []
    private var didShowEventHandlers: [EventHandler] {
        return handlers.filter { $0.kind == .didShow }
    }
    private var willShowEventHandlers: [EventHandler] {
        return handlers.filter { $0.kind == .willShow }
    }
    
    ///The return handler can be discarded, if it isn't planned to remove the handler before the deinitialization of the AdvancedNavigationController.
    ///As long as the AdvancedNavigationController exists, an added handler is called for the appropriate events. If the AdvancedNavigationController is about to be removed from memory (because no one uses the AdvancedNavigationController), usually all handlers are also freed (if the handler themselves don't refer to the AdvancedNavigationController instance).
    open func add(didShowEventAction action: @escaping EventHandler.Action) -> EventHandler {
        return add(handlerWithAction: action, ofKind: .didShow)
    }
    
    open func add(willShowEventAction action: @escaping EventHandler.Action) -> EventHandler {
        return add(handlerWithAction: action, ofKind: .willShow)
    }
    
    private func add(handlerWithAction action: @escaping EventHandler.Action, ofKind kind: EventHandler.Kind) -> EventHandler {
        //create new handler
        let handler = EventHandler(action: action, kind: kind)
        
        //add it...
        add(eventHandler: handler)
        
        return handler
    }
    
    private func add(eventHandler handler: EventHandler) {
        handlers += [handler]
    }
    open func remove(eventHandler handler: EventHandler) {
        handlers.removeAll { $0 === handler }
    }
}

extension AdvancedNavigationController: UINavigationControllerDelegate {
    //MARK: showing
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        //call the actions
        didShowEventHandlers.forEach { $0.action(viewController) }
    }
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        //call the actions
        willShowEventHandlers.forEach { $0.action(viewController) }
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
open class EventHandler {
    public enum Kind {
        case didShow
        case willShow
    }
    public let kind: Kind
    
    public typealias Action = (UIViewController) -> Void
    public let action: Action
    
    public init(action: @escaping Action, kind: Kind) {
        self.action = action
        self.kind = kind
    }
}
