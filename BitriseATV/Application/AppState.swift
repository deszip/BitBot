//
//  AppState.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 28.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import Foundation

struct AppState {
    
    var accountsState = AccountsState()
    
    mutating func reduce(_ action: Action) {
        accountsState.reduce(action)
    }
}
