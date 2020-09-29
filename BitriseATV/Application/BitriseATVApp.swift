//
//  BitriseATVApp.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 17.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

@main
struct BitriseATVApp: App {
    
    let dependencyContainer = DependencyContainer()
    let accountsObserver: BRAccountsObserver
        
    let store = Store<AppState, Action>(initial: AppState()) { (state, action) in
        print("Reduce\t\t\t", action)
        state.reduce(action)
    }
    
    init() {
        accountsObserver = dependencyContainer.accountsObserver()
        accountsObserver.dispatchEvents(to: store)
    }
    
    var body: some Scene {
        WindowGroup {
            StoreProvider(store: store) {
                BuildsConnector()
            }
        }
    }
}
