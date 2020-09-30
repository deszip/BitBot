//
//  BuildsView.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 18.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

// TODO: - Extract TabView to higher level

struct BuildsView: View {
    var body: some View {
        TabView {
            Text("hello")
                .tabItem{
                    Text("Builds")
                }
            AccountsConnector()
                .tabItem {
                    Text("Accounts")
                }
        }
    }
}

struct BuildsView_Previews: PreviewProvider {
    static var previews: some View {
        BuildsView()
    }
}
