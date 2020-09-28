//
//  Store.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 28.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import Foundation

final class Store<State, Action> {
    public typealias Reducer = (inout State, Action) -> ()
    private let queue = DispatchQueue(label: "Store queue", qos: .userInitiated)
    
    public init(initial state: State, reducer: @escaping Reducer) {
        self.reducer = reducer
        self.state = state
    }
    
    let reducer: Reducer
    public private(set) var state: State
    
    public func dispatch(action: Action) {
        queue.sync {
            self.reducer(&self.state, action)
            self.observers.forEach(self.notify)
        }
    }
    
    private var observers: Set<Observer<State>> = []
    
    public func subscribe(observer: Observer<State>) {
        queue.sync {
            self.observers.insert(observer)
            self.notify(observer)
        }
    }
    
    /// WARNING: This method must be called on internal queue
    private func notify(_ observer: Observer<State>) {
        let state = self.state
        observer.queue.async {
            let status = observer.observe(state)
            
            if case .dead = status {
                self.queue.async {
                    self.observers.remove(observer)
                }
            }
        }
    }
}
