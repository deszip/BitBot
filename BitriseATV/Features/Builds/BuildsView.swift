//
//  BuildsView.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 18.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct BuildsView<BuildRow: View>: View {
    
    let builds: [BRBuild]
    let row: (BRBuild) -> BuildRow
    
    var body: some View {
        List(builds, id: \.slug) { build in
            row(build)
        }
    }
}

struct BuildsView_Previews: PreviewProvider {
    static var previews: some View {
        BuildsView(builds: [],
                   row: { _ in BuildView(buildColor: .BBSuccessColor,
                                         buildIconImageName: "0-degree-status-icon",
                                         rotation: 0,
                                         userName: "",
                                         buildNumber: "",
                                         appName: "",
                                         branchName: "",
                                         commitMessage: "",
                                         workflow: "",
                                         date: "",
                                         buildingTime: "",
                                         onAppear: {}) })
    }
}
