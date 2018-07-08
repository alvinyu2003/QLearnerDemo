//
//  QButton.swift
//  QLearner
//
//  Created by Alvin Yu on 7/1/18.
//  Copyright © 2018 Alvin Yu. All rights reserved.
//

import UIKit

public class QButton: UIButton {
    
    public struct Configuration {
        let titles: [String]
        let reward: Int
        let maxReward: Int
        let penalty: Int
        let initialQ: [Int]?
        let probabilities: [Double]?
        
        public init(titles: [String],
                    reward: Int = 10,
                    maxReward: Int = 10,
                    penalty: Int = 1,
                    initialQ: [Int]? = nil,
                    probabilities: [Double]? = nil) {
            self.titles = titles
            self.reward = reward
            self.maxReward = maxReward
            self.penalty = penalty
            self.initialQ = initialQ
            self.probabilities = probabilities
        }
    }
    
    private let titles: [String]
    private var Q: [Int]
    private let reward: Int
    private let maxReward: Int
    private let penalty: Int
    private let probabilities: [Double]
    
    required public init(config: Configuration) {
        assert(config.reward >= 0)
        assert(config.penalty < 0)
        assert(config.maxReward >= config.reward)

        titles = config.titles
        reward = config.reward
        maxReward = config.maxReward
        penalty = config.penalty
        
        if let probs = config.probabilities, probs.count == titles.count {
            probabilities = probs
        } else {
            probabilities = Array<Double>(repeating: 1.0, count: titles.count)
        }
        if let startingQ = config.initialQ, startingQ.count == titles.count {
            Q = startingQ
        } else {
            Q = Array<Int>(repeating: 0, count: titles.count)
        }
        
        super.init(frame: .zero)
        addTarget(self, action: #selector(didTap(_:)), for: .touchUpInside)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction private func didTap(_ sender: UIButton) {
        if let title = currentTitle,
            let index = titles.index(where: { title == $0 }) {
            let qsa = Q[index] + reward
            Q[index] = qsa > maxReward ? maxReward : qsa
        }
    }
    
    public func generateCTA() {
        let max = Q.max() ?? 0
        if max > 0 {
            if let index = Q.index(of: max) {
                setTitle(titles[index], for: .normal)
                updateQ(index: index)
            }
        } else {
            let index = randomNumber(probabilities: probabilities)
            setTitle(titles[index], for: .normal)
            updateQ(index: index)
        }
    }
    
    private func updateQ(index: Int) {
        let qsa = Q[index] + penalty
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
