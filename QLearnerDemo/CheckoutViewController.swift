//
//  CheckoutViewController.swift
//  QLearnerDemo
//
//  Created by Alvin Yu on 6/16/18.
//  Copyright © 2018 Alvin Yu. All rights reserved.
//

import UIKit

class CheckoutViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setHidesBackButton(true, animated: false)
        imageView.image = image
    }
    
    @IBAction func done() {
        navigationController?.popToRootViewController(animated: false)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didCheckout"), object: nil)
    }
    
}
