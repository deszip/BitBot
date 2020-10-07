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
    
    @StateObject private var rotator = ListRowViewRotator()
    
    func map(graph: Graph) -> some View {
        var shouldRotate = false
        let buildColor: Color
        let buildIconImageName: String
        switch build.status?.intValue {
        case 0:
            if build.onHold?.boolValue ?? false {
                buildColor = .BBHoldColor
                buildIconImageName = "0-degree-status-icon"
            } else {
                buildIconImageName = "13-degree-status-icon"
                if build.startTime == nil {
                    buildColor = .BBWaitingColor
                } else {
                    buildColor = .BBProgressColor
                    shouldRotate = true
                }
            }
        case 1:
            buildColor = .BBSuccessColor
            buildIconImageName = "success-status-icon"
        case 2:
            buildColor = .BBFailedColor
            buildIconImageName = "failure-status-icon"
        case 3, 4:
            buildColor = .BBAbortedColor
            buildIconImageName = "45-degree-status-icon"
        default:
            buildColor = .BBAbortedColor
            buildIconImageName = "45-degree-status-icon"
        }
        rotator.shouldRotate = shouldRotate
        
        return BuildView(buildColor: buildColor,
                         buildIconImageName: buildIconImageName,
                         rotation: $rotator.rotation,
                         userName: build.app?.account?.username ?? "",
                         buildNumber: build.buildNumber?.stringValue ?? "",
                         appName: build.app?.title ?? "",
                         branchName: build.branch ?? "",
                         commitMessage: build.commitMessage ?? "",
                         workflow: build.workflow ?? "",
                         date: "real date",
                         buildingTime: "reel time")
    }
}
