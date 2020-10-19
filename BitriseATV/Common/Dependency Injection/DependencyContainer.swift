//
//  DependencyContainer.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 29.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import Foundation

final class DependencyContainer {
    private let _persistentContainer: NSPersistentContainer
    private let _store = Store<AppState, Action>(initial: AppState()) { (state, action) in
        print("Reduce\t\t\t", action)
        state.reduce(action)
    }
    
    static let shared = DependencyContainer()
    
    private init() {
        _persistentContainer = BRContainerBuilder().buildContainer()
    }
    
    func store() -> Store<AppState, Action> {
        _store
    }
    
    func accountsObserver() -> BRAccountsObserver {
        BRAccountsObserver(container: persistentContainer())
    }
    
    func bitriseAPI() -> BRBitriseAPI {
        BRBitriseAPI()
    }
    
    func storage() -> BRStorage {
        BRStorage(context: persistentContainer().newBackgroundContext())
    }
    
    func syncEngine() -> BRSyncEngine {
        BRSyncEngine(api: bitriseAPI(),
                     storage: storage())
    }
    
    func commandDispatcher() -> CommandsDispatcher {
        CommandsDispatcher(dependencyContainer: self)
    }
    
    func accountCommandDispatcher() -> AccountCommandsDispatcher {
        AccountCommandsDispatcher(dependencyContainer: self)
    }
    
    func buildCommandDispatcher() -> BuildCommandsDispatcher {
        BuildCommandsDispatcher(dependencyContainer: self)
    }
    
    func persistentContainer() -> NSPersistentContainer {
        _persistentContainer
    }
    
    func commandFactory() -> BRCommandFactory {
        BRCommandFactory(api: bitriseAPI(),
                         syncEngine: syncEngine())
    }
    
    func commandObserver() -> BRObserver {
        BRObserver()
    }
    
    func settingsProvider() -> SettingsProvider {
        SettingsProvider()
    }
    
    func appMetadataProvider() -> AppMetadataProvider {
        AppMetadataProvider()
    }
    
    func remoteStorageChangesObserver() -> RemoteStorageChangesObserver {
        RemoteStorageChangesObserver()
    }
}
