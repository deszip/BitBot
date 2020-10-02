//
//  BuildsConnector.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 28.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct BuildsConnector: Connector {
    func map(graph: Graph) -> some View {
        BuildsView()
    }
}