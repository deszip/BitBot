//
//  CommandsDispatcher.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 08.10.2020.
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
        
        switch state.syncCommandState {
        case .idle:
            break
        case .sync:
            let command = dependencyContainer.commandFactory().syncCommand()
            commands.append(command)
            actions.append(SyncCommandSent())
        }
        commands.forEach {
            $0.execute(nil)
        }
        actions.forEach { store.dispatch(action: $0) }
    }
}
