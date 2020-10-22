//
//  AppView.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 09.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct AppView: View {
    
    let imageURL: URL?
    let appName: String
    let appRepoURL: String
    
    var body: some View {
        Button(action: {}) {
            HStack {
                AsyncImage(url: imageURL)
                    .placeholder(.defaultAvatar)
                    .resizable()
                    .frame(width: 180, height: 180)
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(20)
                VStack(alignment: .leading) {
                    Text(appName)
                    Text(appRepoURL)
                }
                .foregroundColor(.BBBuildTintColor)
                .proximaFont(size: 43, weight: .regular)
            }
        }
        .frame(height: 200)
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(imageURL: nil,
                appName: "name",
                appRepoURL: "repo url")
    }
}
