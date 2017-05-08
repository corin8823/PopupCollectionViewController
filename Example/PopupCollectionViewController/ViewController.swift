//
//  ViewController.swift
//  PopupCollectionViewController
//
//  Created by corin8823 on 04/09/2016.
//  Copyright (c) 2016 corin8823. All rights reserved.
//

import UIKit
import PopupCollectionViewController

class ViewController: UIViewController {

    var vcs = [UIViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()
        let vc1 = DemoViewController()
        vc1.view.backgroundColor = UIColor.red
        vc1.closeButton.setTitle("First", for: .normal)
        let vc2 = DemoViewController()
        vc2.view.backgroundColor = UIColor.blue
        vc2.closeButton.setTitle("Second", for: .normal)
        let vc3 = DemoViewController()
        vc3.view.backgroundColor = UIColor.green
        vc3.closeButton.setTitle("Third", for: .normal)
        self.vcs = [vc1, vc2, vc3]
    }

    @IBAction func didTapLeftButton(_ sender: AnyObject) {
        let gradientLayer = self.createGradientLayer(colors: [UIColor.red, UIColor.blue])
        PopupCollectionViewController(fromVC: self.navigationController!)
            .presentViewControllers(
                self.vcs,
                options: [
                    .cellWidth(300),
                    .popupHeight(400),
                    .overlayLayer(gradientLayer),
                    .layout(.center)
                ], completion: nil)
    }

    @IBAction func didTapRightButton(_ sender: AnyObject) {
        PopupCollectionViewController(fromVC: self.navigationController!)
            .presentViewControllers(
                self.vcs,
                options: [
                    .cellWidth(self.view.bounds.width),
                    .popupHeight(400),
                    .contentEdgeInsets(0),
                    .layout(.center),
                    .animation(.slideLeft)
                ], completion: nil)
    }

    public func createGradientLayer(colors: [UIColor]) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()

        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)

        gradientLayer.colors = colors.map { $0.cgColor }
        return gradientLayer
    }
}

class DemoViewController: UIViewController {

    var closeButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.closeButton.setTitleColor(UIColor.white, for: UIControlState())
        self.closeButton.addTarget(self, action: #selector(DemoViewController.didTapCloseButton), for: .touchUpInside)
        self.view.addSubview(self.closeButton)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.closeButton.sizeToFit()
        self.closeButton.center = self.view.center
    }

    func didTapCloseButton() {
        self.popupCollectionViewController()?.dismiss(completion: nil)
    }
}

extension DemoViewController: PopupViewCellDelegate {

    func popupCollectionViewControllerDidShow(_ viewController: PopupCollectionViewController) {
        print("\(String(describing: self.closeButton.titleLabel?.text))")
    }
}
