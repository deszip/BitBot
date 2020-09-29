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
