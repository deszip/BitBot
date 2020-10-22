//
//  RootView.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 01.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct RootView: View {
    
    var body: some View {
        NavigationView {
            TabView() {
                BuildsConnector()
                    .tabItem {
                        Text("Builds".localized())
                    }
                AccountsConnector()
                    .tabItem {
                        Text("Accounts".localized())
                    }
                SettingsConnector()
                    .tabItem {
                        Text("Settings".localized())
                    }
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
