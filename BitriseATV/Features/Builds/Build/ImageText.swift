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
        HStack(spacing: 15) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
            Text(text)
                .foregroundColor(.BBBuildTintColor)
                .proximaFont(size: 42, weight: .regular)
        }
    }
}

struct ImageText_Previews: PreviewProvider {
    static var previews: some View {
        ImageText(imageName: "", text: "")
    }
}
