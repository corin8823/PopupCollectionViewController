//
//  PopupCollectonViewController.swift
//  PopupCollectonViewController
//
//  Created by corin8823 on 4/9/16.
//  Copyright (c) 2015 corin8823. All rights reserved.
//

import UIKit

public enum PopupCollectionViewControllerOption {
    case layout(PopupCollectionViewController.PopupLayout)
    case animation(PopupCollectionViewController.PopupAnimation)
    case overlayLayer(CALayer)
    case popupHeight(CGFloat)
    case cellWidth(CGFloat)
    case contentEdgeInsets(CGFloat)
}

public protocol PopupViewCellDelegate {

    func popupCollectionViewControllerDidShow(_ viewController: PopupCollectionViewController)
}

open class PopupCollectionViewController: UIViewController {

    public enum PopupLayout {
        case top, center, bottom

        func origin(_ view: UIView) -> CGPoint {
            let size: CGSize = UIScreen.main.bounds.size
            switch self {
            case .top: return CGPoint(x: (size.width - view.frame.width) / 2, y: 0)
            case .center: return CGPoint(x: (size.width - view.frame.width) / 2, y: (size.height - view.frame.height) / 2)
            case .bottom: return CGPoint(x: (size.width - view.frame.width) / 2, y: size.height - view.frame.height)
            }
        }
    }

    public enum PopupAnimation {
        case fadeIn, slideUp, slideLeft
    }

    public enum BackgroundStyle {
        case blackFilter(alpha: CGFloat)
    }

    // Custom Property
    fileprivate var layout: PopupLayout = .center
    fileprivate var animation: PopupAnimation = .slideUp
    fileprivate lazy var overlayLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor(white: 0.0, alpha: 0.4).cgColor
        return layer
    }()
    fileprivate var popupHeight: CGFloat = 400
    fileprivate var cellWidth: CGFloat = 300
    fileprivate var contentEdgeInsets: CGFloat = 24
    open var closedHandler: (() -> Void)?

    fileprivate var popupCollectionView: UICollectionView! {
        didSet {
            self.popupCollectionView.delegate = self
            self.popupCollectionView.dataSource = self
            self.popupCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
            self.popupCollectionView.backgroundColor = .clear
            self.popupCollectionView.decelerationRate = UIScrollViewDecelerationRateFast
            self.popupCollectionView.scrollsToTop = false
            self.popupCollectionView.showsHorizontalScrollIndicator = false
        }
    }

    fileprivate var collectionViewLayout: PagingFlowLayout! {
        didSet {
            self.collectionViewLayout.scrollDirection = .horizontal
            self.collectionViewLayout.pagingDelegate = self
        }
    }

    fileprivate var baseScrollView = UIScrollView()
    fileprivate var defaultContentOffset = CGPoint.zero

    override open func viewDidLoad() {
        super.viewDidLoad()
    }

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.baseScrollView.frame = self.view.frame
        self.baseScrollView.contentInset.top = layout.origin(self.popupCollectionView).y
        self.defaultContentOffset.y = -self.baseScrollView.contentInset.top
    }

    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .all
    }

    override open var shouldAutorotate : Bool {
        return false
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public init(fromVC: UIViewController) {
        self.init()
        fromVC.addChildViewController(self)
        UIApplication.shared.keyWindow?.addSubview(self.view)
        self.didMove(toParentViewController: fromVC)
    }

    open func presentViewControllers(_ viewControllers: [UIViewController], options: [PopupCollectionViewControllerOption]? = nil, completion: (() -> Void)?) {
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

    open func dismiss(completion: (() -> Void)?) {
        let animation = self.animation
        self.hide(animation) {
            self.didClosePopupView()
            completion?()
            self.closedHandler?()
        }
    }

    open func append(childControllers: [UIViewController]) {
        childControllers.forEach {
            self.addChildViewController($0)
        }
        self.popupCollectionView.reloadData()
    }

    func didTapGesture(_ sender: UITapGestureRecognizer) {
        self.dismiss(completion: nil)
    }
}

private extension PopupCollectionViewController {

    func setOptions(_ options: [PopupCollectionViewControllerOption]?) {
        guard let options = options else { return }
        for option in options {
            switch option {
            case .layout(let value):
                self.layout = value
            case .animation(let value):
                self.animation = value
            case .overlayLayer(let value):
                self.overlayLayer = value
            case .popupHeight(let value):
                self.popupHeight = value
            case .cellWidth(let value):
                self.cellWidth = value
            case .contentEdgeInsets(let value):
                self.contentEdgeInsets = value
            }
        }
    }

    func configure() {
        self.collectionViewLayout = PagingFlowLayout()
        self.popupCollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: self.collectionViewLayout)
        self.view.isHidden = true
        self.view.frame = UIScreen.main.bounds

        self.baseScrollView.isScrollEnabled = true
        self.baseScrollView.alwaysBounceHorizontal = false
        self.baseScrollView.alwaysBounceVertical = true
        self.baseScrollView.delegate = self
        self.baseScrollView.frame = self.view.frame
        self.baseScrollView.backgroundColor = .clear
        self.overlayLayer.frame = self.baseScrollView.bounds
        self.view.layer.insertSublayer(overlayLayer, at: 0)
        self.view.addSubview(self.baseScrollView)
        self.baseScrollView.addSubview(self.popupCollectionView)
    }

    func show(_ layout: PopupLayout, animation: PopupAnimation, completion: (() -> Void)?) {
        self.popupCollectionView.frame.size = CGSize(width: UIScreen.main.bounds.width, height: self.popupHeight)
        self.popupCollectionView.frame.origin.x = self.layout.origin(self.popupCollectionView).x

        // add gesture
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapGesture(_:)))
        gestureRecognizer.delegate = self
        self.baseScrollView.addGestureRecognizer(gestureRecognizer)

        switch animation {
        case .fadeIn:
            self.fadeIn(layout) {
                completion?()
            }
        case .slideUp:
            self.slideUp(layout) {
                completion?()
            }
        case .slideLeft:
            self.slideLeft(layout) {
                completion?()
            }
        }
    }

    func hide(_ animation: PopupAnimation, completion: (() -> Void)?) {
        self.popupCollectionView.frame.size = CGSize(width: UIScreen.main.bounds.width, height: self.popupHeight)
        self.popupCollectionView.frame.origin.x = layout.origin(self.popupCollectionView).x
        switch animation {
        case .fadeIn:
            self.fadeOut {
                self.clean()
                completion?()
            }
        case .slideUp:
            self.slideOut {
                self.clean()
                completion?()
            }
        case .slideLeft:
            self.slideLeftOut {
                self.clean()
                completion?()
            }
        }
    }

    func didClosePopupView() {
        self.childViewControllers.forEach {
            $0.removeFromParentViewController()
        }
        self.view.isHidden = true
        self.removeFromParentViewController()
    }

    func clean() {
        self.popupCollectionView.removeFromSuperview()
        self.baseScrollView.removeFromSuperview()
    }
}

private extension PopupCollectionViewController {

    func fadeIn(_ layout: PopupLayout, completion: @escaping () -> Void) {
        self.baseScrollView.contentInset.top = layout.origin(self.popupCollectionView).y
        self.view.isHidden = false
        self.popupCollectionView.alpha = 0.0
        self.view.alpha = 0.0
        self.popupCollectionView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)

        UIView.animate(
            withDuration: 0.3, delay: 0.1, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
                self.popupCollectionView.alpha = 1.0
                self.view.alpha = 1.0
                self.popupCollectionView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: { isFinished in
                completion()
        })
    }

    func fadeOut(_ completion: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
                self.popupCollectionView.alpha = 0.0
                self.view.alpha = 0.0
                self.popupCollectionView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: { isFinished in
                completion()
        })
    }

    func slideUp(_ layout: PopupLayout, completion: @escaping () -> Void) {
        self.baseScrollView.contentInset.top = layout.origin(self.popupCollectionView).y
        self.view.isHidden = false
        self.view.alpha = 0.0
        self.baseScrollView.contentOffset.y = -UIScreen.main.bounds.height

        UIView.animate(
            withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .curveLinear, animations: {
                self.view.alpha = 1.0
                self.baseScrollView.contentOffset.y = -layout.origin(self.popupCollectionView).y
                self.defaultContentOffset = self.baseScrollView.contentOffset
            }, completion: { isFinished in
                completion()
        })
    }

    func slideOut(_ completion: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .curveLinear, animations: {
                self.popupCollectionView.frame.origin.y = UIScreen.main.bounds.height
                self.view.alpha = 0.0
            }, completion: { isFinished in
                completion()
        })
    }

    func slideLeft(_ layout: PopupLayout, completion: @escaping () -> Void) {
        self.baseScrollView.contentInset.top = layout.origin(self.popupCollectionView).y
        self.view.isHidden = false
        self.view.alpha = 0.0
        self.baseScrollView.contentOffset.x = -UIScreen.main.bounds.width
        UIView.animate(
            withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .curveLinear, animations: {
                self.view.alpha = 1.0
                self.baseScrollView.contentOffset.x = -layout.origin(self.popupCollectionView).x
                self.defaultContentOffset = self.baseScrollView.contentOffset
            }, completion: { isFinished in
                completion()
        })
    }

    func slideLeftOut(_ completion: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .curveLinear, animations: {
                self.popupCollectionView.frame.origin.x = UIScreen.main.bounds.width
                self.view.alpha = 0.0
            }, completion: { isFinished in
                completion()
        })
    }
}

extension PopupCollectionViewController: UIScrollViewDelegate {

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let delta = self.defaultContentOffset.y - scrollView.contentOffset.y
        if delta > 50 {
            self.baseScrollView.contentInset.top = -scrollView.contentOffset.y
            self.animation = .slideUp
            self.dismiss(completion: nil)
        }
    }
}

extension PopupCollectionViewController: UICollectionViewDataSource {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.childViewControllers.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
        cell.layer.cornerRadius = 2
        cell.layer.masksToBounds = true

        let vc = self.childViewControllers[indexPath.row]
        vc.view.frame = cell.bounds
        cell.addSubview(vc.view)
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let vc = self.childViewControllers[indexPath.item]
        vc.view.removeFromSuperview()
    }
}

extension PopupCollectionViewController: UICollectionViewDelegateFlowLayout {

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.cellWidth, height: self.popupHeight)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: self.contentEdgeInsets, bottom: 0, right: self.contentEdgeInsets)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.contentEdgeInsets / 2
    }
}

extension PopupCollectionViewController: PagingFlowLayoutDelegate {

    public func collectionView(_ collectionView: UICollectionView, layout pagingFlowLayout: PagingFlowLayout, changePage page: Int) {
        if self.childViewControllers.count > page {
            let vc = self.childViewControllers[page]
            (vc as? PopupViewCellDelegate)?.popupCollectionViewControllerDidShow(self)
        }
    }
}

extension PopupCollectionViewController: UIGestureRecognizerDelegate {

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return gestureRecognizer.view == touch.view
    }
}

extension UIViewController {

    public func popupCollectionViewController() -> PopupCollectionViewController? {
        var parentVC = self.parent
        while !(parentVC is PopupCollectionViewController) {
            parentVC = parentVC?.parent
        }
        return parentVC as? PopupCollectionViewController
    }
}
