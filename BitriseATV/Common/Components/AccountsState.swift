//
//  AccountsState.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 28.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import Foundation

struct AccountsState {
    var hasAccounts: Bool = false
    
    mutating func reduce(_ action: Action) {
        switch action {
        case let action as UpdateAccountsState:
            hasAccounts = action.hasAccounts
        default:
            break
        }
    }
}
