//
//  SettingsState.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 12.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import Foundation

struct SettingsState {
    var analyticsDisabled = false
    
    mutating func reduce(_ action: Action) {
        switch action {
        case let action as UpdateAnalyticsDisabled:
            analyticsDisabled = action.value
        default:
            break
        }
    }
}
