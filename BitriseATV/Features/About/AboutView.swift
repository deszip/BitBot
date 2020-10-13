//
//  AboutView.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 12.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct AboutView: View {
    
    let appVersion: String
    
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
                Text(appVersion)
                    .foregroundColor(.BBBuildTintColor)
                    .proximaFont(size: 40, weight: .regular)
            }
            .frame(maxWidth: .infinity)
            Text(text)
                .proximaFont(size: 33, weight: .regular)
                .foregroundColor(.BBBuildTintColor)
        }
        .frame(maxWidth: .infinity)
    }
}

fileprivate var text = """
BitBot is unofficial Bitrise CI client for tvOS. It uses Bitrise public API for all of it's features. Before use add your personal access token in account list. We wont steal it. We promise :)

Awesome design and tons of patience were contributed by Kotki https://kotki.co 
BitBot was built to work for our current project so it definitely lacks a lot of functionality available via Bitrise API and is full of bugs. Fell free to drop us a line if you found one or need a feature.

BitBot is opensource, feel free to contribute or just blame my code here: https://github.com/deszip/BitBot. If you want to support us - just star the repo :) 
BitBot and we are not associated or affiliated with Bitrise in any way.
"""

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView(appVersion: "1.0.1 (1978)")
    }
}
