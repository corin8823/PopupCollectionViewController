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

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func didTapCollectionPopupButton(sender: AnyObject) {
        let vc1 = DemoViewController()
        vc1.view.backgroundColor = UIColor.redColor()
        let vc2 = DemoViewController()
        vc2.view.backgroundColor = UIColor.blueColor()
        let vc3 = DemoViewController()
        vc3.view.backgroundColor = UIColor.greenColor()
        let vc4 = DemoViewController()
        vc4.view.backgroundColor = UIColor.redColor()
        let vc5 = DemoViewController()
        vc5.view.backgroundColor = UIColor.blueColor()
        let vc6 = DemoViewController()
        vc6.view.backgroundColor = UIColor.greenColor()
        PopupCollectionViewController(fromVC: self.navigationController!)
            .presentViewControllers(
                [vc1, vc2, vc3, vc4, vc5, vc6],
                options: [.CellWidth(300), .PopupHeight(400), .Layout(.Center)],
                completion: nil)
    }
}

class DemoViewController: UIViewController {

}

extension DemoViewController: PopupViewCellDelegate {

    func popupCollectionViewControllerDidShow(viewController: PopupCollectionViewController) {
        print("\(self.view.backgroundColor)")
    }
}