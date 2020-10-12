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
    var appVersion: String = ""
    var buildNumber: String = ""
    
    mutating func reduce(_ action: Action) {
        switch action {
        case let action as UpdateAnalyticsDisabledState:
            analyticsDisabled = action.value
            updateAnalyticsSettingState = .idle
        case let action as UpdateAnalyticsDisabledSetting:
            updateAnalyticsSettingState = .update(value: action.analyticsDisabled)
        case let action as UpdateAppMetadata:
            appVersion = action.version
            buildNumber = action.buildNumber
        default:
            break
        }
    }
}
