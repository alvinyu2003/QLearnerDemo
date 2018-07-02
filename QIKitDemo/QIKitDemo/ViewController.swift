//
//  ViewController.swift
//  QIKitDemo
//
//  Created by Alvin Yu on 7/1/18.
//  Copyright © 2018 Alvin Yu. All rights reserved.
//

import UIKit
import QLearner

class ViewController: UIViewController {

    private var signupButton: QButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addButtons()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        signupButton?.generateCTA()
    }

    func addButtons() {
        let ctas = [("Sign Up", 0.25),
                    ("Sign Up Now", 0.25),
                    ("Sign Me Up", 0.25),
                    ("Register", 0.25)]
        let signup = QButton(ctas: ctas, negativeReinforcement: -1, reward: 3, maxReward: 3)
        signup.translatesAutoresizingMaskIntoConstraints = false
        signup.setTitleColor(.white, for: .normal)
        signup.backgroundColor = .black
        signup.addTarget(self, action: #selector(didTapSignUp(_:)), for: .touchUpInside)
        signupButton = signup
        view.addSubview(signup)
        
        let browse = UIButton()
        browse.translatesAutoresizingMaskIntoConstraints = false
        browse.setTitle("Browse", for: .normal)
        browse.setTitleColor(.white, for: .normal)
        browse.backgroundColor = .black
        browse.addTarget(self, action: #selector(didTapBrowse(_:)), for: .touchUpInside)
        view.addSubview(browse)
        
        let constraints = [
            signup.widthAnchor.constraint(equalToConstant: 200),
            signup.heightAnchor.constraint(equalToConstant: 44),
            signup.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signup.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            browse.widthAnchor.constraint(equalToConstant: 200),
            browse.heightAnchor.constraint(equalToConstant: 44),
            browse.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            browse.bottomAnchor.constraint(equalTo: signup.topAnchor, constant: -20)
        ]
        NSLayoutConstraint.activate(constraints)

        let item = UIBarButtonItem(image: #imageLiteral(resourceName: "settings"), style: .plain, target: self, action: #selector(didTapSettings(_:)))
        self.navigationItem.rightBarButtonItem = item
    }
    
    @IBAction func didTapSignUp(_ sender: UIButton) {
        performSegue(withIdentifier: "signup", sender: nil)
    }

    @IBAction func didTapBrowse(_ sender: UIButton) {
        performSegue(withIdentifier: "browse", sender: nil)
    }
    
    @IBAction func didTapSettings(_ sender: UIButton) {
        performSegue(withIdentifier: "settings", sender: nil)
    }
}

