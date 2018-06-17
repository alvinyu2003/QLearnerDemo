//
//  QLearner.swift
//  Movies
//
//  Created by Alvin Yu on 5/28/18.
//  Copyright © 2018 Alvin Yu. All rights reserved.
//

import Foundation

// These are example states:
// These states model a possible checkout flow.
// enum State: Int {
//    case start = 0
//    case category1
//    case category2
//    case category3
//    case detail1
//    case detail2
//    case checkout
// }

// This is an example reward matrix for the states above:
// The R matrix defines the rewards and penalties for each transition.
// `nil` values represent invalid transitions
// In this example, `start` can transition to `category1`, `category2`, `category3`
// `category1`, `category2`, and `category3` can transition to `detail1` and `detail2`
// `detail1` and `detail2` can transition to `checkout`
//    var R: [[Int?]] = [
//        [nil, 0, 0, 0, nil , nil, nil],
//        [-1, nil, nil, nil, 0, 0, nil],
//        [-1, nil, nil, nil, 0, 0, nil],
//        [-1, nil, nil, nil, 0, 0, nil],
//        [nil, -1, -1, -1, nil, nil, 5],
//        [nil, -1, -1, -1, nil, nil, 5],
//        [0, nil, nil, nil, nil, nil, nil]
//    ]

// This is an example Q matrix for the states above:
// The Q matrix is the same dimension as the R matrix and is initialized with zeros.
//    var Q: [[Float]] = [
//        [0, 0, 0, 0, 0, 0, 0],
//        [0, 0, 0, 0, 0, 0, 0],
//        [0, 0, 0, 0, 0, 0, 0],
//        [0, 0, 0, 0, 0, 0, 0],
//        [0, 0, 0, 0, 0, 0, 0],
//        [0, 0, 0, 0, 0, 0, 0],
//        [0, 0, 0, 0, 0, 0, 0]
//        ]
// Discussion: Given enough data (about users similar to the current user) the Q Matrix can be initialized with none zero values.

// QLearner models only need to implement this protocol.
/// The Q matrix is updated using the `transition(from:, to:)` the function.
/// The next state can be determined by calling `next(from:)` the function.
public protocol QLearnerProtocol {
    func updateQ(from: Int, to: Int)
    func next(from current: Int) -> Int?
}

/// This class is used to apply Reinforcement Learning to User Interfaces.
/// It needs to be initialized with an R matrix, a start state and a goal state.
public class QLearner: QLearnerProtocol {
    
    enum Status {
        case explore, exploit, reward, penalize
    }
    
    private(set) var start: Int
    private(set) var goal: Int
    private(set) var R: [[Int?]]
    private(set) var Q: [[Float]]
    private(set) var status: Status = .explore
    private var stack = Stack<Transition>()
    
    public init(start: Int, goal: Int, R: [[Int?]]) {
        assert(R.count == R[0].count)
        self.start = start
        self.goal = goal
        self.R = R
        Q = Array(repeating: Array(repeating: 0.0, count: R[0].count), count: R.count)
    }
    
    public func updateQ(from: Int, to: Int) {
        if from == start {
            while let _ = stack.pop() {
                // reset the stack
            }
            stack.push(Transition(from: from, to: to))
        } else if to == goal {
            stack.push(Transition(from: from, to: to))
            
            while let previous = stack.pop() {
                reward(current: previous.from, next: previous.to)
            }
        } else if let previous = stack.peek(), from == previous.to, to == previous.from {
            penalize(current: from, next: to)
            // alternatively, if the reward is negative then penalize the previous transition/state
            let _ = stack.pop()
        } else {
            stack.push(Transition(from: from, to: to))
        }
    }
    
    public func next(from current: Int) -> Int? {
        let states = Q[current]
        let threshold: Float = 0
        let nextState: Int?
        
        if states.reduce(0, +) > threshold {
            let max = states.max() ?? 0.0
            nextState = states.index(of: max)
            status = .exploit
        } else {
            var actions = [Int]()
            for (i, reward) in R[current].enumerated() {
                if let _ = reward {
                    actions.append(i)
                }
            }
            nextState = actions.shuffled().first
            status = .explore
        }
        return nextState
    }
    
    public func printQ() {
        print("Q:")
        Q.forEach { print($0) }
    }
    
    public func printStatus() {
        debugPrint(status)
    }
    
    private func reward(current: Int, next: Int, alpha: Float = 1.0, gamma: Float = 0.8) {
        guard let rsa = R[current][next] else { return }
        let qsa = Q[current][next]
        
        let maxNextQ = Q[next].max() ?? 0.0
        let new_q = qsa + alpha * (Float(rsa) + gamma * maxNextQ - qsa)
        Q[current][next] = new_q > 0 ? new_q : 0 // TODO: normalize if needed
        status = .reward
    }
    
    private func penalize(current: Int, next: Int) {
        guard let rsa = R[current][next] else { return }
        let qsa = Q[next][current] // these indexes are swapped
        let new_q = qsa + Float(rsa)
        Q[next][current] = new_q > 0 ? new_q : 0 // these indexes are swapped
        status = .penalize
    }
    
}
