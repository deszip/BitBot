//
//  AccountsConnector.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 29.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct AccountsFlow<A: View, E: View>: View {
    let hasAccounts: Bool
    
    let accounts: () -> A
    let emptyState: () -> E
    
    var body: some View {
        if hasAccounts {
            accounts()
        } else {
            emptyState()
        }
    }
}

struct AccountsConnector: Connector {
    
    @StateObject private var accountsProvider = AccountsProvider(persistentContainer: DependencyContainer.shared.persistentContainer())
    
    func map(graph: Graph) -> some View {
        
        AccountsFlow(hasAccounts: graph.accounts.hasAccounts,
                     accounts: { accountsView(graph: graph) },
                     emptyState: { EmptyStateView() })
    }
}

private extension AccountsConnector {
    func accountsView(graph: Graph) -> some View {
        let displayAddAccountView = Binding<Bool>(get: { graph.accounts.displayAddAccountView },
                                                  set: { graph.accounts.displayAddAccountView = $0 })
        let accounts = accountsProvider.accounts.map { AccountViewModel(userName: $0.username ?? "",
                                                                        email: $0.email ?? "") }
        return AccountsView(displayAddAccountView: displayAddAccountView,
                            accounts: accounts,
                            accountRow: { AccountConnector(accountViewModel: $0) })
    }
}
