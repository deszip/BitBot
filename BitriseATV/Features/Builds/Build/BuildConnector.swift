//
//  BuildConnector.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 06.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct BuildConnector: Connector {
    var build: BRBuild
    
    func map(graph: Graph) -> some View {
        BuildView(userName: build.app?.account?.username ?? "",
                  buildNumber: build.buildNumber?.stringValue ?? "",
                  appName: build.app?.title ?? "",
                  branchName: build.branch ?? "",
                  commitMessage: build.commitMessage ?? "",
                  workflow: build.workflow ?? "",
                  date: "real date",
                  buildingTime: "reel time")
    }
}
