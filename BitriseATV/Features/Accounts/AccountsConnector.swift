//
//  AccountsConnector.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 29.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct AccountsConnector: Connector {
    
    @StateObject private var accountsProvider = DataProvider<BTRAccount>(persistentContainer: DependencyContainer.shared.persistentContainer(),
                                                                         sortKey: "username",
                                                                         ascending: true)
    
    func map(graph: Graph) -> some View {
        return AccountsView(accounts: accountsProvider.data,
                            accountRow: { AccountConnector(account: $0) })
    }
}
