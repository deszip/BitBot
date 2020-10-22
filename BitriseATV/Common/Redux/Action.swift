//
//  Action.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 28.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import Foundation

protocol Action {}

struct UpdateAccountsState: Action {
    var hasAccounts: Bool
}

struct AddPersonalAccessToken: Action {
    var token: String
}

struct SendPersonalAccessToken: Action {}

struct DeleteAccount: Action {
    var slug: String
}

struct DeleteAccountCommandSent: Action {}

struct RebuildCommand: Action {
    var build: BRBuild
}

struct RebuildCommandSent: Action {}

struct AbortBuildCommand: Action {
    var build: BRBuild
}

struct AbortBuildCommandSent: Action {}

struct SyncCommand: Action {}

struct SyncCommandSent: Action {}

struct UpdateAnalyticsDisabledState: Action {
    var value: Bool
}

struct UpdateAnalyticsDisabledSetting: Action {
    var analyticsDisabled: Bool
}

struct UpdateAppMetadata: Action {
    var version: String
    var buildNumber: String
}
