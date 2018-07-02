//
//  QButton.swift
//  QLearner
//
//  Created by Alvin Yu on 7/1/18.
//  Copyright © 2018 Alvin Yu. All rights reserved.
//

import UIKit

public class QButton: UIButton {
    
    // This is an example usage
    // Negative Reinforcement of -1
    // Reward of 3
    // Max Reward of 3
    //    cta: (title, probability)
    //    [
    //        ("Sign Up", 0.33),
    //        ("Sign Up Now", 0.33),
    //        ("Sign Me Up", 0.33)
    //    ]

    private let ctas: [(title: String, probability: Double)]
    private var Q: [Int]
    private let neg: Int
    private let reward: Int
    private let maxReward: Int
    
    required public init(ctas: [(String, Double)], negativeReinforcement: Int = 1, reward: Int, maxReward: Int) {
        assert(maxReward >= reward)
        assert(negativeReinforcement < 0)
        self.ctas = ctas
        self.reward = reward
        self.maxReward = maxReward
        neg = negativeReinforcement
        Q = Array(repeating: 0, count: ctas.count)
        super.init(frame: .zero)
        addTarget(self, action: #selector(didTap(_:)), for: .touchUpInside)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction private func didTap(_ sender: UIButton) {
        if let title = currentTitle,
            let index = ctas.index(where: { title == $0.title }) {
            let qsa = Q[index] + reward
            Q[index] = qsa > maxReward ? maxReward : qsa
        }
    }
    
    public func generateCTA() {
        let max = Q.max() ?? 0
        if max > 0 {
            if let index = Q.index(of: max) {
                setTitle(ctas[index].title, for: .normal)
                updateQ(index: index)
            }
        } else {
            let index = randomNumber(probabilities: ctas.map { $0.probability })
            setTitle(ctas[index].title, for: .normal)
            updateQ(index: index)
        }
    }
    
    private func updateQ(index: Int) {
        let qsa = Q[index] + neg
        Q[index] = qsa > 0 ? qsa : 0
    }
    
    private func randomNumber(probabilities: [Double]) -> Int {
        // Sum of all probabilities (so that we don't have to require that the sum is 1.0):
        let sum = probabilities.reduce(0, +)
        // Random number in the range 0.0 <= rnd < sum :
        let rnd = sum * Double(arc4random_uniform(UInt32.max)) / Double(UInt32.max)
        
        // Find the first interval of accumulated probabilities into which `rnd` falls:
        var accum = 0.0
        for (i, p) in probabilities.enumerated() {
            accum += p
            if rnd < accum {
                return i
            }
        }
        // This point might be reached due to floating point inaccuracies:
        return (probabilities.count - 1)
    }

}
