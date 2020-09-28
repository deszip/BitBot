//
//  StoreProvider.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 28.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct StoreProvider<Content: View>: View {
    let store: Store<AppState, Action>
    let content: () -> Content
    
    var body: some View {
        content().environmentObject(EnvironmentStore(store: store))
    }
}
