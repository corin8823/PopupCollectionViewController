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
        vc1.view.backgroundColor = UIColor.redColor()
        vc1.closeButton.setTitle("First", forState: .Normal)
        let vc2 = DemoViewController()
        vc2.view.backgroundColor = UIColor.blueColor()
        vc2.closeButton.setTitle("Second", forState: .Normal)
        let vc3 = DemoViewController()
        vc3.view.backgroundColor = UIColor.greenColor()
        vc3.closeButton.setTitle("Third", forState: .Normal)
        self.vcs = [vc1, vc2, vc3]
    }

    @IBAction func didTapLeftButton(sender: AnyObject) {
        PopupCollectionViewController(fromVC: self.navigationController!)
            .presentViewControllers(
                self.vcs,
                options: [.CellWidth(300), .PopupHeight(400), .Layout(.Center)],
                completion: nil)
    }

    @IBAction func didTapRightButton(sender: AnyObject) {
        PopupCollectionViewController(fromVC: self.navigationController!)
            .presentViewControllers(
                self.vcs,
                options: [
                    .CellWidth(self.view.bounds.width),
                    .PopupHeight(400),
                    .ContentEdgeInsets(0),
                    .Layout(.Center),
                    .Animation(.SlideLeft)
                ],
                completion: nil)
    }
}

class DemoViewController: UIViewController {

    var closeButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.closeButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.closeButton.addTarget(self, action: #selector(DemoViewController.didTapCloseButton), forControlEvents: .TouchUpInside)
        self.view.addSubview(self.closeButton)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.closeButton.sizeToFit()
        self.closeButton.center = self.view.center
    }

    func didTapCloseButton() {
        self.popupCollectionViewController()?.dismissViewController(nil)
    }
}

extension DemoViewController: PopupViewCellDelegate {

    func popupCollectionViewControllerDidShow(viewController: PopupCollectionViewController) {
        print("\(self.closeButton.titleLabel?.text)")
    }
}