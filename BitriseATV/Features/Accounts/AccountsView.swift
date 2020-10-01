//
//  AccountsView.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 29.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct AccountsView<AccountRow: View>: View {
    
    @Binding var displayAddAccountView: Bool
    var accounts: [AccountViewModel]
    
    let accountRow: (AccountViewModel) -> AccountRow
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Add account".localized(),
                               destination: AddAccountConnector(),
                               isActive: $displayAddAccountView)
                ForEach(accounts) { account in
                    accountRow(account)
                }
            }
        }
    }
}

struct AccountsView_Previews: PreviewProvider {
    static var previews: some View {
        let displayAddAccountView = Binding(get: { false }, set: { _ in })
        AccountsView(displayAddAccountView: displayAddAccountView,
                     accounts: [],
                     accountRow: { _ in AccountView(userName: "test",
                                                    email: "test@email.com")})
    }
}
