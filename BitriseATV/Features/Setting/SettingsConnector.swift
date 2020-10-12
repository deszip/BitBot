//
//  SettingsConnector.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 12.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct SettingsConnector: Connector {
    func map(graph: Graph) -> some View {
        let disableAnalytics = Binding(get: { graph.settingsNode.disableAnalytics },
                                       set: { graph.settingsNode.disableAnalytics = $0 })
        return SettingsView(disableAnalytics: disableAnalytics)
    }
}
