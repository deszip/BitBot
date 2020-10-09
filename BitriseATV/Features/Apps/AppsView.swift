//
//  AppsView.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 09.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct AppsView<AppRow: View>: View {
    
    let apps: [BRApp]
    let row: (BRApp) -> AppRow
    
    var body: some View {
        NavigationView {
            List(apps, id: \.slug) { app in
                row(app)
            }
            .navigationTitle("Apps".localized())
        }
    }
}

struct AppsView_Previews: PreviewProvider {
    static var previews: some View {
        AppsView(apps: [],
                 row: { _ in Text("") })
    }
}
