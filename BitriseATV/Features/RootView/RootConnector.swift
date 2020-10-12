//
//  RootConnector.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 01.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct RootConnector: Connector {
    func map(graph: Graph) -> some View {
        return RootView()
    }
}
