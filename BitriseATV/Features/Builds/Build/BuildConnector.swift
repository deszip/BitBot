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
    
    @StateObject private var rotator = ObservableTimer<Double>(initialValue: 0,
                                                               timeInterval: 1 / 360) {
        if $0 < 360 {
            return $0 + 1
        } else {
            return 0
        }
    }
    
    var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "dd.MM.yyyy '@' HH:mm"
        return dateFormatter
    }()
    
    func map(graph: Graph) -> some View {
        var shouldRotate = false
        let buildColor: Color
        let buildIconImageName: String
        var shouldStartTimer = false
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
                    shouldStartTimer = true
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
        if shouldStartTimer {
            rotator.start()
        } else {
            rotator.finish()
        }
        
        return BuildView(buildColor: buildColor,
                         buildIconImageName: buildIconImageName,
                         rotation: $rotator.value,
                         userName: build.app?.account?.username ?? "",
                         buildNumber: build.buildNumber?.stringValue ?? "",
                         appName: build.app?.title ?? "",
                         branchName: build.branch ?? "",
                         commitMessage: build.commitMessage ?? "no commit message".localized(),
                         workflow: build.workflow ?? "",
                         date: build.triggerTime.flatMap { dateFormatter.string(from: $0) } ?? "",
                         buildingTime: "reel time")
    }
}
