//
//  BuildsConnector.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 28.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct BuildsFlow<B: View, E: View>: View {
    let hasAccounts: Bool
    let builds: () -> B
    let emptyState: () -> E
    
    var body: some View {
        if hasAccounts {
            builds()
        } else {
            emptyState()
        }
    }
}

struct BuildsConnector: Connector {
    
    @StateObject private var buildsProvider = DataProvider<BRBuild>(persistentContainer: DependencyContainer.shared.persistentContainer(),
                                                                    sortKey: "triggerTime",
                                                                    ascending: false)
    
    func map(graph: Graph) -> some View {
        BuildsFlow(hasAccounts: graph.accounts.hasAccounts,
                   builds: { BuildsView(builds: buildsProvider.data,
                                        row: { BuildConnector(build: $0) }) },
                   emptyState: { EmptyStateView() })
    }
}
