//
//  AccountsView.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 29.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct AccountsView: View {
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Add account".localized(),
                               destination: AddAccountConnector())
            }
        }
    }
}

struct AccountsView_Previews: PreviewProvider {
    static var previews: some View {
        AccountsView()
    }
}
