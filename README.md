# PopupCollectionViewController

[![CI Status](http://img.shields.io/travis/corin8823/PopupCollectionViewController.svg?style=flat)](https://travis-ci.org/corin8823/PopupCollectionViewController)
[![Version](https://img.shields.io/cocoapods/v/PopupCollectionViewController.svg?style=flat)](http://cocoapods.org/pods/PopupCollectionViewController)
[![License](https://img.shields.io/cocoapods/l/PopupCollectionViewController.svg?style=flat)](http://cocoapods.org/pods/PopupCollectionViewController)
[![Platform](https://img.shields.io/cocoapods/p/PopupCollectionViewController.svg?style=flat)](http://cocoapods.org/pods/PopupCollectionViewController)

## Description and [appetize.io`s DEMO](https://appetize.io/app/q4n81yf0aakkx20x2cejh107b4)

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
        .CellWidth(self.view.bounds.width),
        .PopupHeight(400),
        .ContentEdgeInsets(0),
        .Layout(.Center),
        .Animation(.SlideLeft)
    ],
    completion: nil)
```


## Requirements
- iOS 8.0+
- Xcode 7

## Installation

PopupCollectionViewController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
use_frameworks!
pod "PopupCollectionViewController"
```

## Customization
- `case Layout(PopupCollectionViewController.PopupLayout)`
- `case Animation(PopupCollectionViewController.PopupAnimation)`
- `case OverlayColor(UIColor)`
- `case PopupHeight(CGFloat)`
- `case CellWidth(CGFloat)`
- `case ContentEdgeInsets(CGFloat)`

## Acknowledgments

Inspired by [PopupController](https://github.com/daisuke310vvv/PopupController) in [daisuke310vvv](https://github.com/daisuke310vvv)

## License

PopupCollectionViewController is available under the MIT license. See the LICENSE file for more info.
