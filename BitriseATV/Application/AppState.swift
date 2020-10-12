//
//  AppState.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 28.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import Foundation

struct AppState {
    
    enum SyncCommandState {
        case idle
        case sync
    }
    
    var syncCommandState: SyncCommandState = .idle
    var accountsState = AccountsState()
    var buildsState = BuildsState()
    var settingsState = SettingsState()
    
    mutating func reduce(_ action: Action) {
        accountsState.reduce(action)
        buildsState.reduce(action)
        settingsState.reduce(action)
        switch action {
        case is SyncCommand:
            syncCommandState = .sync
        case is SyncCommandSent:
            syncCommandState = .idle
        default: break
        }
    }
}
