//
//  DetailViewController.swift
//  QLearnerDemo
//
//  Created by Alvin Yu on 6/16/18.
//  Copyright © 2018 Alvin Yu. All rights reserved.
//

import UIKit

protocol DetailViewControllerDelegate {
    func didTapBackButton(from: CheckoutAgent.State)
}

class DetailViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var button: UIBarButtonItem!
    
    var image: UIImage?
    var delegate: DetailViewControllerDelegate?
    var currentState: CheckoutAgent.State?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image
        
        if let state = currentState, state == .detail2 {
            button.title = "Buy Now"
            imageView.contentMode = .scaleAspectFit
        } else {
            button.title = "Buy"
            imageView.contentMode = .scaleAspectFill
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if navigationController?.viewControllers.index(of: self) == nil {
            if let currentState = currentState {
                delegate?.didTapBackButton(from: currentState)
            }
        }
    }
    
    @IBAction func buy() {
        performSegue(withIdentifier: "checkoutSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let checkout = segue.destination as? CheckoutViewController {
            checkout.image = image
            if let state = currentState {
                CheckoutAgent.shared.transition(from: state, to: .checkout)
            }
        }
    }
}

