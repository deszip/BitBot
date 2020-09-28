//
//  Graph.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 28.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import Foundation

struct Graph {
    public init(state: AppState, dispatch: @escaping (Action) -> ()) {
        self.state = state
        self.dispatch = dispatch
    }
    
    let state: AppState
    let dispatch: (Action) -> ()
}
