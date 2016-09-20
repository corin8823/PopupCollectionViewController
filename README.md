# PopupCollectionViewController

[![CI Status](http://img.shields.io/travis/corin8823/PopupCollectionViewController.svg?style=flat)](https://travis-ci.org/corin8823/PopupCollectionViewController)
[![Version](https://img.shields.io/cocoapods/v/PopupCollectionViewController.svg?style=flat)](http://cocoapods.org/pods/PopupCollectionViewController)
[![License](https://img.shields.io/cocoapods/l/PopupCollectionViewController.svg?style=flat)](http://cocoapods.org/pods/PopupCollectionViewController)
[![Platform](https://img.shields.io/cocoapods/p/PopupCollectionViewController.svg?style=flat)](http://cocoapods.org/pods/PopupCollectionViewController)

## Description and [appetize.io`s DEMO](https://appetize.io/app/8ugdc3jamzhx9ar4j2tnqx189w)

![](https://github.com/corin8823/PopupCollectionViewController/blob/master/ScreenShots/Screenshot.gif)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

```swift
let popupVC = PopupCollectionViewController(fromVC: self)
popupVC.presentViewControllers([UIViewController()], completion: nil)
```


### Custom

```swift
let popupVC = PopupCollectionViewController(fromVC: self)
popupVC.presentViewControllers([UIViewController(), UIViewController()],
    options: [
        .cellWidth(self.view.bounds.width),
        .popupHeight(400),
        .contentEdgeInsets(0),
        .layout(.Center),
        .animation(.SlideLeft)
    ],
    completion: nil)
```


## Requirements
- iOS 8.0+
- swift 3.0

If you use Swift 2.2 or 2.3, try PopupCollectionViewController 0.0.1.

## Installation

PopupCollectionViewController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
use_frameworks!
pod "PopupCollectionViewController"
```

## Customization
- `case layout(PopupCollectionViewController.PopupLayout)`
- `case animation(PopupCollectionViewController.PopupAnimation)`
- `case overlayColor(UIColor)`
- `case popupHeight(CGFloat)`
- `case cellWidth(CGFloat)`
- `case contentEdgeInsets(CGFloat)`

## Acknowledgments

Inspired by [PopupController](https://github.com/daisuke310vvv/PopupController) in [daisuke310vvv](https://github.com/daisuke310vvv)

## License

PopupCollectionViewController is available under the MIT license. See the LICENSE file for more info.
