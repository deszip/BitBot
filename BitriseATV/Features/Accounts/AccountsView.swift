//
//  AccountsView.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 29.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct AccountsView: View {
    
    @Binding var displayAddAccountView: Bool
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Add account".localized(),
                               destination: AddAccountConnector(),
                               isActive: $displayAddAccountView)
            }
        }
    }
}

struct AccountsView_Previews: PreviewProvider {
    static var previews: some View {
        let displayAddAccountView = Binding(get: { false }, set: { _ in })
        AccountsView(displayAddAccountView: displayAddAccountView)
    }
}
