//
//  SettingsState.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 12.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import Foundation

struct SettingsState {
    
    enum AnalyticsSettingsState {
        case idle
        case update(value: Bool)
    }
    
    var analyticsDisabled = false
    var updateAnalyticsSettingState: AnalyticsSettingsState = .idle
    
    mutating func reduce(_ action: Action) {
        switch action {
        case let action as UpdateAnalyticsDisabled:
            analyticsDisabled = action.value
            updateAnalyticsSettingState = .idle
        case let action as UpdateSettings:
            updateAnalyticsSettingState = .update(value: action.analyticsDisabled)
        default:
            break
        }
    }
}
