//
//  AccountsState.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 28.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import Foundation

struct AccountsState {
    
    enum AddAccountCommand {
        case idle
        case execute(token: String)
    }
    
    enum DeleteAccountCommand {
        case idle
        case execute(slug: String)
    }
    
    var hasAccounts: Bool = false
    var addAccountsCommand: AddAccountCommand = .idle
    var deleteAccountCommand: DeleteAccountCommand = .idle
    
    mutating func reduce(_ action: Action) {
        switch action {
        case let action as UpdateAccountsState:
            hasAccounts = action.hasAccounts
        case let action as AddPersonalAccessToken:
            addAccountsCommand = .execute(token: action.token)
        case is SendPersonalAccessToken:
            addAccountsCommand = .idle
        case let action as DeleteAccount:
            deleteAccountCommand = .execute(slug: action.slug)
        case is DeleteAccountCommandSent:
            deleteAccountCommand = .idle
        default:
            break
        }
    }
}
