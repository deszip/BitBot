//
//  CommandsDispatcher.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 30.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import Foundation

final class CommandsDispatcher {
    private let queue = DispatchQueue(label: "com.bitrise.commands_dispatcher")
    private let dependencyContainer: DependencyContainer
    private var store: Store<AppState, Action> {
        dependencyContainer.store()
    }
    
    init(dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer
    }
}

extension CommandsDispatcher {
    var asObserver: Observer<AppState> {
        Observer(queue: self.queue) { state in
            self.observe(state: state)
            return .active
        }
    }
    
    private func observe(state: AppState) {
        
        var commands: [BRCommand] = []
        var actions: [Action] = []
        switch state.accountsState.addAccountsCommand {
        case .idle:
            break
        case .execute(let token):
            commands.append(BRGetAccountCommand(syncEngine: dependencyContainer.syncEngine(),
                                                token: token))
            actions.append(SendPersonalAccessToken())
        }
        switch state.accountsState.deleteAccountCommand {
        case .idle:
            break
        case .execute(let slug):
            commands.append(BRRemoveAccountCommand(api: dependencyContainer.bitriseAPI(),
                                                   storage: dependencyContainer.storage(),
                                                   slug: slug))
            actions.append(DeleteAccountCommandSent())
        }
        switch state.buildsState.rebuildCommandState {
        case .idle:
            break
        case .rebuild(let build):
            let command = dependencyContainer.commandFactory().rebuildCommand(build)
            commands.append(command)
            actions.append(RebuildCommandSent())
        }
        switch state.buildsState.abortBuildCommandState {
        case .idle:
            break
        case .abort(let build):
            let command = dependencyContainer.commandFactory().abortCommand(build)
            commands.append(command)
            actions.append(AbortBuildCommandSent())
        }
        commands.forEach { $0.execute(nil) }
        actions.forEach { store.dispatch(action: $0) }
    }
}
