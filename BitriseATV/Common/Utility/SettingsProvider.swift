//
//  SettingsProvider.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 12.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import Foundation

class SettingsProvider {
    
    private let queue = DispatchQueue(label: "SettingsProviderQueue")
    private let userDefaults: UserDefaults = .standard
    private var store: Store<AppState, Action> {
        DependencyContainer.shared.store()
    }
    
    func load() {
        let action = UpdateAnalyticsDisabled(value: userDefaults.bool(forKey: Constants.analyticsAvailabilityKey))
        store.dispatch(action: action)
    }
}

extension SettingsProvider {
    var asObserver: Observer<AppState> {
        Observer(queue: self.queue) { state in
            self.observe(state: state)
            return .active
        }
    }
    
    private func observe(state: AppState) {
        switch state.settingsState.updateAnalyticsSettingState {
        case .idle:
            break
        case .update(let value):
            userDefaults.setValue(value, forKey: Constants.analyticsAvailabilityKey)
            load()
        }
    }
}

private extension SettingsProvider {
    enum Constants {
        static let analyticsAvailabilityKey = "kBRAnalyticsAvailabilityKey"
    }
}
