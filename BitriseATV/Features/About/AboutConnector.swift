//
//  AboutConnector.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 12.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct AboutConnector: Connector {
    func map(graph: Graph) -> some View {
        AboutView(appVersion: "\(graph.settingsNode.appVersion) (\(graph.settingsNode.buildNumber))")
    }
}
