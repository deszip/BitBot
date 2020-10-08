//
//  AppState.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 28.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import Foundation

struct AppState {
    
    enum RootTab {
        case builds
        case accounts
    }
    
    var rootTab: RootTab = .builds
    var accountsState = AccountsState()
    var buildsState = BuildsState()
    
    mutating func reduce(_ action: Action) {
        accountsState.reduce(action)
        buildsState.reduce(action)
        switch action {
        case let action as UpdateAccountsState:
            if action.hasAccounts {
                rootTab = .builds
            } else {
                rootTab = .accounts
            }
        case let action as UpdateSelectedTab:
            rootTab = action.tab
        default: break
        }
    }
}
