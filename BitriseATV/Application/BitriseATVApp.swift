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
    
    let dependencyContainer = DependencyContainer.shared
    let store: Store<AppState, Action>
    let accountsObserver: BRAccountsObserver
    let commandsDispatcher: CommandsDispatcher
    
    init() {
        store = dependencyContainer.store()
        accountsObserver = dependencyContainer.accountsObserver()
        accountsObserver.dispatchEvents(to: store)
        commandsDispatcher = dependencyContainer.commandDispatcher()
        store.subscribe(observer: commandsDispatcher.asObserver)
    }
    
    var body: some Scene {
        WindowGroup {
            StoreProvider(store: store) {
                BuildsConnector()
            }
        }
    }
}
