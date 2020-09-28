//
//  BuildsConnector.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 28.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct BuildsFlow<E: View, B: View>: View {
    let hasAccounts: Bool
    
    let emptyState: () -> E
    let builds: () -> B
    
    var body: some View {
        if hasAccounts {
            builds()
        } else {
            emptyState()
        }
    }
}

struct BuildsConnector: Connector {
    func map(graph: Graph) -> some View {
        BuildsFlow(hasAccounts: graph.accounts.hasAccounts,
                   emptyState: { EmptyStateView() },
                   builds: { BuildsView() })
    }
}
