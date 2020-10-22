//
//  AccountsNode.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 28.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import Foundation

extension Graph {
    var accounts: AccountsNode { AccountsNode(graph: self) }
}

struct AccountsNode {
    let graph: Graph
    
    var hasAccounts: Bool { graph.state.accountsState.hasAccounts }
    
    func add(personalAccessToken: String) {
        graph.dispatch(AddPersonalAccessToken(token: personalAccessToken))
    }
    
    func deleteAccount(withSlug slug: String) {
        graph.dispatch(DeleteAccount(slug: slug))
    }
}
