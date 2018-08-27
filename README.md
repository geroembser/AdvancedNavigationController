#  AdvancedNavigationController

## Installation

Preferred installation is using [CocoaPods](https://cocoapods.org).

To Integrate the `AdvancedNavigationController` into your project using CocoaPods, specify it in your  `Podfile`:
```
pod 'AdvancedNavigationController'
```

## Usage
For an example, see the [sample project](Example) included in this repo.

```
//Create instance and use it
let nc = AdvancedNavigationController()

let willShowEventHandler = nc.add(willShowEventAction: { (showingViewController) in
    //do something with the ViewController that is about to go on screen (but not yet finally visible until didShow occurred)
})

let didShowEventHandler = nc.add(didShowEventAction: { (showedViewController) in
    //do something with the ViewController that was shown (i. e. now visible on screen)
})

let willPopEventHandler = nc.add(willPopEventAction: { (poppingViewController) in
    //do something with the ViewController that is about to popped from screen
    //Note: it is possible that popping is interrupted (e.g. by interactive swipe back)
})

let didPopEventHandler = nc.add(didPopEventAction: { (poppedViewController) in
    //do something with the ViewController that was popped from screen
})

//Note: we use `_` (underscore) here to discard the result, because for the whole lifetime of the `nc` instance, we're interested in doing a specific action when pushing occurs
_ = nc.add(willPushEventAction: { (pushingViewController) in
    //do something with the ViewController that is about to be pushed on screen
})
_ = nc.add(didPushEventAction: { (pushedViewController) in
    //do something with the ViewController that was pushed on screen
})

//after a specific event, we can remove the added event handlers, to no longer perform the specified actions
nc.remove(eventHandlers:[willShowEventHandler, willPopEventHandler])
```

## Example
This is the example app...
![example app animated gif](.github/AdvancedNavigationController%20Example%20Video.gif)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
