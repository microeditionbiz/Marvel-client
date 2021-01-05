//
//  AsyncOperation.swift
//  MEKit
//
//  Created by Pablo Ezequiel Romero Giovannoni on 24/04/2020.
//  Copyright © 2020 Pablo Ezequiel Romero Giovannoni. All rights reserved.
//

import Foundation

class AsyncOperation: Operation {

    private enum State: String {
        case ready = "isReady"
        case executing = "isExecuting"
        case finished = "isFinished"
    }
    
    private var state: State = .ready {
        willSet {
            willChangeValue(forKey: newValue.rawValue)
            willChangeValue(forKey: state.rawValue)
        }
        didSet {
            didChangeValue(forKey: oldValue.rawValue)
            didChangeValue(forKey: state.rawValue)
        }
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override var isReady: Bool {
        return state == .ready
    }
    
    override var isExecuting: Bool {
        return state == .executing
    }
    
    override var isFinished: Bool {
        return state == .finished
    }
    
    override func start() {
        guard !isCancelled else {
            finish()
            return
        }
        if !isExecuting {
            state = .executing
        }
        main()
    }
    
    func finish() {
        if isExecuting {
            state = .finished
        }
    }
    
    override func cancel() {
        super.cancel()
        finish()
    }
    
}
