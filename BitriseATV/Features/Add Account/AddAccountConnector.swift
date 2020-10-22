//
//  AddAccountConnector.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 29.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct AddAccountConnector: Connector {
    func map(graph: Graph) -> some View {
        AddAccountView(commitTokenAction: graph.accounts.add(personalAccessToken:))
    }
}
