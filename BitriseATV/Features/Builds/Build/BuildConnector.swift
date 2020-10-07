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
    
    @StateObject private var rotator = ObservableTimer(timeInterval: 1 / 360)
    @State private var rotation: Double = 0
    @StateObject private var buildRunningTimer = ObservableTimer(timeInterval: 1)
    @State private var buildingTime: String = ""
    
    var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "dd.MM.yyyy '@' HH:mm"
        return dateFormatter
    }()
    
    var durationFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "m'm' s's'"
        return dateFormatter
    }()
    
    func map(graph: Graph) -> some View {
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
            buildRunningTimer.start()
        } else {
            rotator.finish()
            buildRunningTimer.finish()
            rotation = 0
        }
        let rotator = self.rotator
        let buildRunningTimer = self.buildRunningTimer
        let build = self.build
        let durationFormatter = self.durationFormatter
        let onAppear: () -> Void = {
            rotator.action = {
                if rotation < 360 {
                    rotation += 1
                } else {
                    rotation = 0
                }
            }
            buildRunningTimer.action = {
                let buildDuration = build.envPrepareFinishedTime.flatMap { Date().timeIntervalSince($0) } ?? 0
                let durationDate = Date(timeIntervalSince1970: buildDuration)
                buildingTime = durationFormatter.string(from: durationDate)
            }
            buildRunningTimer.action?()
        }
        return BuildView(buildColor: buildColor,
                         buildIconImageName: buildIconImageName,
                         rotation: rotation,
                         userName: build.app?.account?.username ?? "",
                         buildNumber: "#\(build.buildNumber?.stringValue ?? "")",
                         appName: build.app?.title ?? "",
                         branchName: build.branch ?? "",
                         commitMessage: build.commitMessage ?? "no commit message".localized(),
                         workflow: build.workflow ?? "",
                         date: build.triggerTime.flatMap { dateFormatter.string(from: $0) } ?? "",
                         buildingTime: buildingTime,
                         onAppear: onAppear)
    }
}
