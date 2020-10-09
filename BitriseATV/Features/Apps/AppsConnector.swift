//
//  AppsConnector.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 09.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct AppsConnector: Connector {
    
    let apps: [BRApp]
    
    func map(graph: Graph) -> some View {
        AppsView(apps: apps,
                 row: { AppConnector(app: $0) })
    }
    
}
