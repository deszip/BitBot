//
//  SettingsNode.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 12.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import Foundation

extension Graph {
    var settingsNode: SettingsNode { SettingsNode(graph: self) }
}

struct SettingsNode {
    
    let graph: Graph
    
    var disableAnalytics: Bool {
        get { graph.state.settingsState.analyticsDisabled }
        nonmutating set { graph.dispatch(UpdateAnalyticsDisabledSetting(analyticsDisabled: newValue)) }
    }
    
    var appVersion: String {
        graph.state.settingsState.appVersion
    }
    
    var buildNumber: String {
        graph.state.settingsState.buildNumber
    }
}
