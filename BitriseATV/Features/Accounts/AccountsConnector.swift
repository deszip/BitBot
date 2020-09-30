//
//  AccountsConnector.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 29.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct AccountsConnector: Connector {
    func map(graph: Graph) -> some View {
        let displayAddAccountView = Binding<Bool>(get: { graph.accounts.displayAddAccountView },
                                                  set: { graph.accounts.displayAddAccountView = $0 })
        return AccountsView(displayAddAccountView: displayAddAccountView)
    }
}
