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
    let accountCommandsDispatcher: AccountCommandsDispatcher
    let buildCommandsDispatcher: BuildCommandsDispatcher
    let commandObserver: BRObserver
    let settingsProvider: SettingsProvider
    
    init() {
        store = dependencyContainer.store()
        accountsObserver = dependencyContainer.accountsObserver()
        accountsObserver.dispatchEvents(to: store)
        commandsDispatcher = dependencyContainer.commandDispatcher()
        store.subscribe(observer: commandsDispatcher.asObserver)
        accountCommandsDispatcher = dependencyContainer.accountCommandDispatcher()
        store.subscribe(observer: accountCommandsDispatcher.asObserver)
        buildCommandsDispatcher = dependencyContainer.buildCommandDispatcher()
        store.subscribe(observer: buildCommandsDispatcher.asObserver)
        commandObserver = dependencyContainer.commandObserver()
        commandObserver.startObserving(dependencyContainer.commandFactory().syncCommand())
        settingsProvider = dependencyContainer.settingsProvider()
        store.subscribe(observer: settingsProvider.asObserver)
        settingsProvider.load()
    }
    
    var body: some Scene {
        WindowGroup {
            StoreProvider(store: store) {
                RootConnector()
            }
        }
    }
}
