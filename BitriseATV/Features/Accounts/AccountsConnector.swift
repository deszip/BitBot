//
//  AccountsConnector.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 29.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct AccountsConnector: Connector {
    
    @StateObject private var accountsProvider = AccountsProvider(persistentContainer: DependencyContainer.shared.persistentContainer())
    
    func map(graph: Graph) -> some View {
        let displayAddAccountView = Binding<Bool>(get: { graph.accounts.displayAddAccountView },
                                                  set: { graph.accounts.displayAddAccountView = $0 })
        let accounts = accountsProvider.accounts.map { AccountViewModel(name: $0.email ?? "") }
        return AccountsView(displayAddAccountView: displayAddAccountView,
                            accounts: accounts)
    }
}
