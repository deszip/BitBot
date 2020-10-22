//
//  BRAccountsObserver+Dispatch.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 29.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import Foundation

extension BRAccountsObserver {
    func dispatchEvents(to store: Store<AppState, Action>) {
        store.dispatch(action: UpdateAccountsState(hasAccounts: false))
        self.start { (state) in
            let hasAccounts: Bool
            switch state {
            case .empty:
                hasAccounts = false
            case .hasData:
                hasAccounts = true
            @unknown default:
                hasAccounts = false
            }
            store.dispatch(action: UpdateAccountsState(hasAccounts: hasAccounts))
        }
    }
}
