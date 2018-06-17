//
//  CategoryViewController.swift
//  QLearnerDemo
//
//  Created by Alvin Yu on 6/16/18.
//  Copyright © 2018 Alvin Yu. All rights reserved.
//

import UIKit

struct Category {
    
    static var men: [UIImage] = [ #imageLiteral(resourceName: "ian-dooley-347943-unsplash"), #imageLiteral(resourceName: "eliud-gil-samaniego-68734-unsplash"), #imageLiteral(resourceName: "freestocks-org-62602-unsplash"), #imageLiteral(resourceName: "jaunt-and-joy-658006-unsplash"), #imageLiteral(resourceName: "jonathan-francisca-227556-unsplash"), #imageLiteral(resourceName: "alex-holyoake-235022-unsplash"), #imageLiteral(resourceName: "michael-frattaroli-234664-unsplash"), #imageLiteral(resourceName: "gez-xavier-mansfield-284653-unsplash") ]
    static var women: [UIImage] = [ #imageLiteral(resourceName: "drew-roberts-344778-unsplash"), #imageLiteral(resourceName: "daniel-apodaca-400019-unsplash"), #imageLiteral(resourceName: "elijah-m-henderson-194586-unsplash"), #imageLiteral(resourceName: "serrah-galos-598535-unsplash"), #imageLiteral(resourceName: "brooke-cagle-195780-unsplash"), #imageLiteral(resourceName: "jamakassi-364678-unsplash"), #imageLiteral(resourceName: "ian-dooley-347962-unsplash"), #imageLiteral(resourceName: "allef-vinicius-180699-unsplash") ]
    static var home: [UIImage] = [ #imageLiteral(resourceName: "sarah-dorweiler-357724-unsplash"), #imageLiteral(resourceName: "tan-erica-438857-unsplash"), #imageLiteral(resourceName: "becca-tapert-391584-unsplash"), #imageLiteral(resourceName: "han-vi-ph-m-th-467381-unsplash"), #imageLiteral(resourceName: "samule-sun-473504-unsplash"), #imageLiteral(resourceName: "lauren-mancke-60547-unsplash"), #imageLiteral(resourceName: "kari-shea-109894-unsplash"), #imageLiteral(resourceName: "sarah-dorweiler-105892-unsplash") ]
    
}

class CategoryViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    var currentState: CheckoutAgent.State = .start
    var dataSource: [UIImage]?
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        registerForNotifications()
    }
    
    private func configureCollectionView() {
        let width = view.bounds.width
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: width / 2.0, height: 200.0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func registerForNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setupInitialState),
                                               name: NSNotification.Name(rawValue: "didCheckout"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setupInitialState),
                                               name: NSNotification.Name.UIApplicationDidBecomeActive,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(resignActive),
                                               name: NSNotification.Name.UIApplicationWillResignActive,
                                               object: nil)
    }
    
    @objc func resignActive() {
        CheckoutAgent.shared.transition(from: currentState, to: .start)
    }
    
    @objc func setupInitialState() {
        guard let state = CheckoutAgent.shared.next(from: .start) else { return }
        currentState = state
        switch currentState {
        case .category1:
            dataSource = Category.men
        case .category2:
            dataSource = Category.women
        default:
            dataSource = Category.home
        }
        collectionView.reloadData()
        CheckoutAgent.shared.transition(from: .start, to: currentState)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailViewController = segue.destination as? DetailViewController {
            if let nextState = CheckoutAgent.shared.next(from: currentState) {
                detailViewController.image = selectedImage
                detailViewController.delegate = self
                detailViewController.currentState = nextState
                CheckoutAgent.shared.transition(from: currentState, to: nextState)
            }
        }
    }
}

extension CategoryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ImageCollectionViewCell else { fatalError() }
        cell.imageView.image = dataSource?[indexPath.row]
        return cell
    }
    
}

extension CategoryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedImage = dataSource?[indexPath.row]
        performSegue(withIdentifier: "detailSegue", sender: nil)
    }
    
}

extension CategoryViewController: DetailViewControllerDelegate {
    
    func didTapBackButton(from: CheckoutAgent.State) {
        CheckoutAgent.shared.transition(from: from, to: currentState)
    }
    
}
