//
//  AppMetadataProvider.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 12.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import Foundation

class AppMetadataProvider {
    func load(to store: Store<AppState, Action>) {
        guard let infoDictionary = Bundle.main.infoDictionary,
              let version = infoDictionary["CFBundleShortVersionString"] as? String,
              let buildNumber = infoDictionary["CFBundleVersion"] as? String else { return }
        store.dispatch(action: UpdateAppMetadata(version: version,
                                                 buildNumber: buildNumber))
    }
}
