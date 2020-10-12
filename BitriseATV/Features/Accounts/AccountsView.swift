//
//  AccountsView.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 29.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct AccountsView<AccountRow: View>: View {

    var accounts: [BTRAccount]
    
    let accountRow: (BTRAccount) -> AccountRow
    
    var body: some View {
        List {
            NavigationLink("Add account".localized(),
                           destination: AddAccountConnector())
                .proximaFont(size: 43, weight: .regular)
                .foregroundColor(.BBBuildTintColor)
            ForEach(accounts, id: \.slug) { account in
                accountRow(account)
            }
        }
    }
}

struct AccountsView_Previews: PreviewProvider {
    static var previews: some View {
        AccountsView(accounts: [],
                     accountRow: { _ in AccountView(imageURL: nil,
                                                    userName: "test",
                                                    email: "test@email.com",
                                                    deleteAction: {},
                                                    destination: { Text("") })})
    }
}
