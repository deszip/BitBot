//
//  BuildsView.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 18.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct BuildsView: View {
    
    let builds: [BRBuild]
    
    var body: some View {
        List(builds, id: \.slug) { build in
            Button(action: {}, label: {
                Text(build.slug ?? "")
            })
        }
    }
}

struct BuildsView_Previews: PreviewProvider {
    static var previews: some View {
        BuildsView(builds: [])
    }
}
