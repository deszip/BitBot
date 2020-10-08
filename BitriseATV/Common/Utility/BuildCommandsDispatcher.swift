//
//  BuildCommandsDispatcher.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 08.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import Foundation

final class BuildCommandsDispatcher {
    private let queue = DispatchQueue(label: "com.bitrise.build_commands_dispatcher")
    private let dependencyContainer: DependencyContainer
    private var store: Store<AppState, Action> {
        dependencyContainer.store()
    }
    
    init(dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer
    }
}

extension BuildCommandsDispatcher {
    var asObserver: Observer<AppState> {
        Observer(queue: self.queue) { state in
            self.observe(state: state)
            return .active
        }
    }
    
    private func observe(state: AppState) {
        
        var commands: [BRCommand] = []
        var actions: [Action] = []
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
        commands.forEach {
            $0.execute { [weak self] (result, _) in
                if result {
                    self?.store.dispatch(action: SyncCommand())
                }
            }
        }
        actions.forEach { store.dispatch(action: $0) }
    }
}
