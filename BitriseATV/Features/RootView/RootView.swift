//
//  RootView.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 01.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct RootView: View {
    
    @Binding var selectedTabIndex: AppState.RootTab
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTabIndex) {
                BuildsConnector()
                    .tabItem {
                        Text("Builds".localized())
                    }
                    .tag(AppState.RootTab.builds)
                AccountsConnector()
                    .tabItem {
                        Text("Accounts".localized())
                    }
                    .tag(AppState.RootTab.accounts)
                SettingsConnector()
                    .tabItem {
                        Text("Settings".localized())
                    }
                    .tag(AppState.RootTab.settings)
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        let binding = Binding(get: { AppState.RootTab.builds }, set: { _ in })
        RootView(selectedTabIndex: binding)
    }
}
