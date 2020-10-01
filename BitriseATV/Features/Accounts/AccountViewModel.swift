//
//  AccountViewModel.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 30.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import Foundation

struct AccountViewModel: Identifiable {
    let id = UUID()
    let userName: String
    let email: String
}
