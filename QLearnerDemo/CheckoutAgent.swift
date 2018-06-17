//
//  CheckoutAgent.swift
//  QLearnerDemo
//
//  Created by Alvin Yu on 6/16/18.
//  Copyright © 2018 Alvin Yu. All rights reserved.
//

import QLearner

class CheckoutAgent {
    
    enum State: Int {
        case start = 0
        case category1
        case category2
        case category3
        case detail1
        case detail2
        case checkout
    }
    
    static let shared = CheckoutAgent()
    
    private let learner = QLearner(start: 0,
                                   goal: 6,
                                   R: [
                                    [nil, 0, 0, 0, nil , nil, nil],
                                    [-1, nil, nil, nil, 0, 0, nil],
                                    [-1, nil, nil, nil, 0, 0, nil],
                                    [-1, nil, nil, nil, 0, 0, nil],
                                    [nil, -1, -1, -1, nil, nil, 5],
                                    [nil, -1, -1, -1, nil, nil, 5],
                                    [0, nil, nil, nil, nil, nil, nil]
        ])
    
    func next(from current: State) -> State? {
        guard let next = learner.next(from: current.rawValue) else { return nil }
        let nextState = State(rawValue: next)
        learner.printStatus()
        debugPrint(nextState ?? "")
        return nextState
    }
    
    func transition(from: State, to: State) {
        learner.updateQ(from: from.rawValue, to: to.rawValue)
        print("Update Q")
        learner.printQ()
    }
    
}
