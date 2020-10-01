//
//  EmptyStateView.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 18.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct EmptyStateView: View {
    
    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                Image("EmptyIcon")
                Text("No Accounts yet".localized().uppercased())
                    .proximaFont(size: 50, weight: .regular)
                    .foregroundColor(.BBBuildTintColor)
                Text("Let’s add the first one by adding your Bitrise\npersonal access token. It’s secure, trust us.".localized())
                    .proximaFont(size: 28, weight: .regular)
                    .foregroundColor(.BBBuildTintColor)
                NavigationLink("Add Account".localized(), destination: AddAccountConnector())
                        .proximaFont(size: 28, weight: .regular)
            }
        }
    }
}

struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyStateView()
    }
}
