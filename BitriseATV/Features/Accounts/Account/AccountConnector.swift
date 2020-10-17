//
//  AccountConnector.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 01.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct AccountConnector: Connector {
    
    let account: BTRAccount
    
    func map(graph: Graph) -> some View {
        AccountView(imageURL: account.avatarURL.flatMap { URL(string: $0) },
                    userName: account.username ?? "",
                    email: account.email ?? "" ,
                    deleteAction: { graph.accounts.deleteAccount(withSlug: account.slug ?? "") },
                    destination: { AppsConnector(apps: Array(account.apps ?? [])) })
    }
}
