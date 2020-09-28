//
//  EnvironmentStore.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 28.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

class EnvironmentStore: ObservableObject {
    @Published private (set) var graph: Graph
    
    let store: Store<AppState, Action>
    
    init(store: Store<AppState, Action>) {
        self.store = store
        self.graph = Graph(state: store.state, dispatch: store.dispatch(action:))
        
        store.subscribe(observer: asObserver)
    }
    
    private var asObserver: Observer<AppState> {
        Observer(queue: .main) { state in
            self.graph = Graph(state: state, dispatch: self.store.dispatch(action:))
            return .active
        }
    }
}
