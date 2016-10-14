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
        vc1.closeButton.setTitle("First", for: UIControlState())
        let vc2 = DemoViewController()
        vc2.view.backgroundColor = UIColor.blue
        vc2.closeButton.setTitle("Second", for: UIControlState())
        let vc3 = DemoViewController()
        vc3.view.backgroundColor = UIColor.green
        vc3.closeButton.setTitle("Third", for: UIControlState())
        self.vcs = [vc1, vc2, vc3]
    }

    @IBAction func didTapLeftButton(_ sender: AnyObject) {
        PopupCollectionViewController(fromVC: self.navigationController!)
            .presentViewControllers(
                self.vcs,
                options: [.cellWidth(300), .popupHeight(400), .layout(.center)],
                completion: nil)
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
                ],
                completion: nil)
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
        self.popupCollectionViewController()?.dismissViewController(nil)
    }
}

extension DemoViewController: PopupViewCellDelegate {

    func popupCollectionViewControllerDidShow(_ viewController: PopupCollectionViewController) {
        print("\(self.closeButton.titleLabel?.text)")
    }
}
