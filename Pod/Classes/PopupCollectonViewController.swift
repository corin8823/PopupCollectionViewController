//
//  PopupCollectonViewController.swift
//  PopupCollectonViewController
//
//  Created by corin8823 on 4/9/16.
//  Copyright (c) 2015 corin8823. All rights reserved.
//

import UIKit

public enum PopupCollectionViewControllerOption {
    case Layout(PopupCollectionViewController.PopupLayout)
    case Animation(PopupCollectionViewController.PopupAnimation)
    case OverlayColor(UIColor)
    case PopupHeight(CGFloat)
    case CellWidth(CGFloat)
    case ContentEdgeInsets(CGFloat)
}

public protocol PopupViewCellDelegate {

    func popupCollectionViewControllerDidShow(viewController: PopupCollectionViewController)
}

public class PopupCollectionViewController: UIViewController {

    public enum PopupLayout {
        case Top, Center, Bottom

        func origin(view: UIView) -> CGPoint {
            let size: CGSize = UIScreen.mainScreen().bounds.size
            switch self {
            case .Top: return CGPoint(x: (size.width - view.frame.width) / 2, y: 0)
            case .Center: return CGPoint(x: (size.width - view.frame.width) / 2, y: (size.height - view.frame.height) / 2)
            case .Bottom: return CGPoint(x: (size.width - view.frame.width) / 2, y: size.height - view.frame.height)
            }
        }
    }

    public enum PopupAnimation {
        case FadeIn, SlideUp, SlideLeft
    }

    public enum BackgroundStyle {
        case BlackFilter(alpha: CGFloat)
    }

    // Custom Property
    private var layout: PopupLayout = .Center
    private var animation: PopupAnimation = .SlideUp
    private var overlayColor: UIColor = UIColor(white: 0.0, alpha: 0.4)
    private var popupHeight: CGFloat = 400
    private var cellWidth: CGFloat = 300
    private var contentEdgeInsets: CGFloat = 24
    public var closedHandler: (() -> Void)?

    private var popupCollectionView: UICollectionView! {
        didSet {
            self.popupCollectionView.delegate = self
            self.popupCollectionView.dataSource = self
            self.popupCollectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
            self.popupCollectionView.backgroundColor = UIColor.clearColor()
            self.popupCollectionView.decelerationRate = UIScrollViewDecelerationRateFast
            self.popupCollectionView.scrollsToTop = false
            self.popupCollectionView.showsHorizontalScrollIndicator = false
        }
    }

    private var collectionViewLayout: PagingFlowLayout! {
        didSet {
            self.collectionViewLayout.scrollDirection = .Horizontal
            self.collectionViewLayout.pagingDelegate = self
        }
    }

    private var baseScrollView = UIScrollView()
    private var defaultContentOffset = CGPoint.zero

    override public func viewDidLoad() {
        super.viewDidLoad()
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.baseScrollView.frame = self.view.frame
        self.baseScrollView.contentInset.top = layout.origin(self.popupCollectionView).y
        self.defaultContentOffset.y = -self.baseScrollView.contentInset.top
    }

    override public func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .All
    }

    override public func shouldAutorotate() -> Bool {
        return false
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public init(fromVC: UIViewController) {
        self.init()
        fromVC.addChildViewController(self)
        UIApplication.sharedApplication().keyWindow?.addSubview(self.view)
        self.didMoveToParentViewController(fromVC)
    }

    public func presentViewControllers(viewControllers: [UIViewController], options: [PopupCollectionViewControllerOption]? = nil, completion: (() -> Void)?) {
        for viewController in viewControllers {
            self.addChildViewController(viewController)
        }
        self.setOptions(options)
        self.configure()
        self.show(self.layout, animation: self.animation) {
            self.defaultContentOffset = self.baseScrollView.contentOffset
            completion?()
        }
    }

    public func dismissViewController(completion: (() -> Void)?) {
        let animation = self.animation ?? .SlideUp
        self.hide(animation) {
            self.didClosePopupView()
            completion?()
            self.closedHandler?()
        }
    }

    public func appendChildViewControllers(childControllers: [UIViewController]) {
        for vc in childControllers {
            self.addChildViewController(vc)
        }
        self.popupCollectionView.reloadData()
    }
}

private extension PopupCollectionViewController {

    func setOptions(options: [PopupCollectionViewControllerOption]?) {
        guard let options = options else { return }
        for option in options {
            switch option {
            case .Layout(let value):
                self.layout = value
            case .Animation(let value):
                self.animation = value
            case .OverlayColor(let value):
                self.overlayColor = value
            case .PopupHeight(let value):
                self.popupHeight = value
            case .CellWidth(let value):
                self.cellWidth = value
            case .ContentEdgeInsets(let value):
                self.contentEdgeInsets = value
            }
        }
    }

    func configure() {
        self.collectionViewLayout = PagingFlowLayout()
        self.popupCollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: self.collectionViewLayout)
        self.view.hidden = true
        self.view.frame = UIScreen.mainScreen().bounds

        self.baseScrollView.scrollEnabled = true
        self.baseScrollView.alwaysBounceHorizontal = false
        self.baseScrollView.alwaysBounceVertical = true
        self.baseScrollView.delegate = self
        self.baseScrollView.frame = self.view.frame
        self.baseScrollView.backgroundColor = self.overlayColor
        self.view.addSubview(self.baseScrollView)
        self.baseScrollView.addSubview(self.popupCollectionView)
    }

    @objc func didTapGesture(sender: UITapGestureRecognizer) {
        self.dismissViewController(nil)
    }

    func registerTapGesture() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapGesture(_:)))
        gestureRecognizer.delegate = self
        self.baseScrollView.addGestureRecognizer(gestureRecognizer)
    }

    func show(layout: PopupLayout, animation: PopupAnimation, completion: (() -> Void)?) {
        self.popupCollectionView.frame.size = CGSize(width: UIScreen.mainScreen().bounds.width, height: self.popupHeight)
        self.popupCollectionView.frame.origin.x = self.layout.origin(self.popupCollectionView).x
        self.registerTapGesture()
        switch animation {
        case .FadeIn:
            self.fadeIn(layout) {
                completion?()
            }
        case .SlideUp:
            self.slideUp(layout) {
                completion?()
            }
        case .SlideLeft:
            self.slideLeft(layout) {
                completion?()
            }
        }
    }

    func hide(animation: PopupAnimation, completion: (() -> Void)?) {
        self.popupCollectionView.frame.size = CGSize(width: UIScreen.mainScreen().bounds.width, height: self.popupHeight)
        self.popupCollectionView.frame.origin.x = layout.origin(self.popupCollectionView).x
        switch animation {
        case .FadeIn:
            self.fadeOut {
                self.clean()
                completion?()
            }
        case .SlideUp:
            self.slideOut {
                self.clean()
                completion?()
            }
        case .SlideLeft:
            self.slideLeftOut {
                self.clean()
                completion?()
            }
        }
    }

    func didClosePopupView() {
        for vc in self.childViewControllers {
            vc.removeFromParentViewController()
        }
        self.view.hidden = true
        self.removeFromParentViewController()
    }

    func clean() {
        self.popupCollectionView.removeFromSuperview()
        self.baseScrollView.removeFromSuperview()
    }
}

private extension PopupCollectionViewController {

    func fadeIn(layout: PopupLayout, completion: () -> Void) {
        self.baseScrollView.contentInset.top = layout.origin(self.popupCollectionView).y
        self.view.hidden = false
        self.popupCollectionView.alpha = 0.0
        self.baseScrollView.alpha = 0.0
        self.popupCollectionView.transform = CGAffineTransformMakeScale(0.9, 0.9)

        UIView.animateWithDuration(
            0.3, delay: 0.1, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .CurveEaseInOut, animations: {
                self.popupCollectionView.alpha = 1.0
                self.baseScrollView.alpha = 1.0
                self.popupCollectionView.transform = CGAffineTransformMakeScale(1.0, 1.0)
            }, completion: { isFinished in
                completion()
        })
    }

    func fadeOut(completion: () -> Void) {
        UIView.animateWithDuration(
            0.3, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .CurveEaseInOut, animations: {
                self.popupCollectionView.alpha = 0.0
                self.baseScrollView.alpha = 0.0
                self.popupCollectionView.transform = CGAffineTransformMakeScale(0.9, 0.9)
            }, completion: { isFinished in
                completion()
        })
    }

    func slideUp(layout: PopupLayout, completion: () -> Void) {
        self.baseScrollView.contentInset.top = layout.origin(self.popupCollectionView).y
        self.view.hidden = false
        self.baseScrollView.alpha = 0.0
        self.baseScrollView.contentOffset.y = -UIScreen.mainScreen().bounds.height

        UIView.animateWithDuration(
            0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .CurveLinear, animations: {
                self.baseScrollView.alpha = 1.0
                self.baseScrollView.contentOffset.y = -layout.origin(self.popupCollectionView).y
                self.defaultContentOffset = self.baseScrollView.contentOffset
            }, completion: { isFinished in
                completion()
        })
    }

    func slideOut(completion: () -> Void) {
        UIView.animateWithDuration(
            0.5, delay: 0.1, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .CurveLinear, animations: {
                self.popupCollectionView.frame.origin.y = UIScreen.mainScreen().bounds.height
                self.baseScrollView.alpha = 0.0
            }, completion: { isFinished in
                completion()
        })
    }

    func slideLeft(layout: PopupLayout, completion: () -> Void) {
        self.baseScrollView.contentInset.top = layout.origin(self.popupCollectionView).y
        self.view.hidden = false
        self.baseScrollView.alpha = 0.0
        self.baseScrollView.contentOffset.x = -UIScreen.mainScreen().bounds.width
        UIView.animateWithDuration(
            0.5, delay: 0.1, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .CurveLinear, animations: {
                self.baseScrollView.alpha = 1.0
                self.baseScrollView.contentOffset.x = -layout.origin(self.popupCollectionView).x
                self.defaultContentOffset = self.baseScrollView.contentOffset
            }, completion: { isFinished in
                completion()
        })
    }

    func slideLeftOut(completion: () -> Void) {
        UIView.animateWithDuration(
            0.5, delay: 0.1, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .CurveLinear, animations: {
                self.popupCollectionView.frame.origin.x = UIScreen.mainScreen().bounds.width
                self.baseScrollView.alpha = 0.0
            }, completion: { isFinished in
                completion()
        })
    }
}

extension PopupCollectionViewController: UIScrollViewDelegate {

    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let delta = self.defaultContentOffset.y - scrollView.contentOffset.y
        if delta > 50 {
            self.baseScrollView.contentInset.top = -scrollView.contentOffset.y
            self.animation = .SlideUp
            self.dismissViewController(nil)
        }
    }
}

extension PopupCollectionViewController: UICollectionViewDataSource {

    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.childViewControllers.count
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("UICollectionViewCell", forIndexPath: indexPath)
        cell.layer.cornerRadius = 2
        cell.layer.masksToBounds = true

        let vc = self.childViewControllers[indexPath.item]
        vc.view.frame = cell.bounds
        cell.addSubview(vc.view)
        return cell
    }

    public func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let vc = self.childViewControllers[indexPath.item]
        vc.view.removeFromSuperview()
    }
}

extension PopupCollectionViewController: UICollectionViewDelegateFlowLayout {

    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: self.cellWidth, height: self.popupHeight)
    }

    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: self.contentEdgeInsets, bottom: 0, right: self.contentEdgeInsets)
    }

    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return self.contentEdgeInsets / 2
    }
}

extension PopupCollectionViewController: PagingFlowLayoutDelegate {

    public func collectionView(collectionView: UICollectionView, layout pagingFlowLayout: PagingFlowLayout, changePage page: Int) {
        let vc = self.childViewControllers[page]
        (vc as? PopupViewCellDelegate)?.popupCollectionViewControllerDidShow(self)
    }
}

extension PopupCollectionViewController: UIGestureRecognizerDelegate {

    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return gestureRecognizer.view == touch.view
    }
}

extension UIViewController {

    public func popupCollectionViewController() -> PopupCollectionViewController? {
        var parentVC = self.parentViewController
        while !(parentVC is PopupCollectionViewController) {
            parentVC = parentVC?.parentViewController
        }
        return parentVC as? PopupCollectionViewController
    }
}