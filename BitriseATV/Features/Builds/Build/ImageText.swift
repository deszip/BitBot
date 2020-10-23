//
//  ImageText.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 07.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct ImageText: View {
    
    let imageName: String
    let text: String
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 15) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
                .colorMultiply(.BBBuildTintColor)
            Text(text)
                .lineLimit(1)
                .foregroundColor(.BBBuildTintColor)
                .proximaFont(size: 42, weight: .regular)
        }
    }
}

struct ImageText_Previews: PreviewProvider {
    static var previews: some View {
        ImageText(imageName: "calendar",
                  text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum")
    }
}
