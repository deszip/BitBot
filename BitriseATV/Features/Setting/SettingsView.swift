//
//  SettingsView.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 12.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    @Binding var disableAnalytics: Bool
    
    var body: some View {
            HStack {
                VStack {
                    Image.icon
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                        .frame(width: 400)
                    Text("BitBot")
                        .foregroundColor(.BBBuildTintColor)
                        .proximaFont(size: 70, weight: .regular)
                }
                .frame(maxWidth: .infinity)
                List {
                    NavigationLink(
                        destination: Text("about"),
                        label: {
                            Text("About".localized())
                                .foregroundColor(.BBBuildTintColor)
                                .proximaFont(size: 43, weight: .regular)
                        })
                    Toggle(isOn: $disableAnalytics, label: {
                        Text("Disable analytics".localized())
                            .foregroundColor(.BBBuildTintColor)
                            .proximaFont(size: 43, weight: .regular)
                    })
                    .proximaFont(size: 43, weight: .regular)
                }
                .frame(maxWidth: .infinity)
            }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let binding = Binding(get: { false }, set: { _ in })
        SettingsView(disableAnalytics: binding)
    }
}
