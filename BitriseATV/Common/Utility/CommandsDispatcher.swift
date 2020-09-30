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
        let command: BRCommand
        let action: Action
        switch state.accountsState.addAccountsCommand {
        case .idle:
            return
        case .execute(let token):
            command = BRGetAccountCommand(syncEngine: dependencyContainer.syncEngine(),
                                          token: token)
            action = SendPersonalAccessToken()
        }
        command.execute()
        store.dispatch(action: action)
    }
}
