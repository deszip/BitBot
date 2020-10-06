//
//  BuildsConnector.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 28.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct BuildsConnector: Connector {
    
    @StateObject private var buildsProvider = DataProvider<BRBuild>(persistentContainer: DependencyContainer.shared.persistentContainer(),
                                                                    sortKey: "triggerTime",
                                                                    ascending: false)
    
    func map(graph: Graph) -> some View {
        BuildsView(builds: buildsProvider.data,
                   row: { BuildConnector(build: $0) })
    }
}
