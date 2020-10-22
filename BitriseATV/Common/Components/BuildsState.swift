//
//  BuildsState.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 08.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import Foundation

struct BuildsState {
    enum RebuildCommandState {
        case idle
        case rebuild(build: BRBuild)
    }
    
    enum AbortBuildCommandState {
        case idle
        case abort(build: BRBuild)
    }
    
    var rebuildCommandState: RebuildCommandState = .idle
    var abortBuildCommandState: AbortBuildCommandState = .idle
    
    mutating func reduce(_ action: Action) {
        switch action {
        case let action as RebuildCommand:
            rebuildCommandState = .rebuild(build: action.build)
        case is RebuildCommandSent:
            rebuildCommandState = .idle
        case let action as AbortBuildCommand:
            abortBuildCommandState = .abort(build: action.build)
        case is AbortBuildCommandSent:
            abortBuildCommandState = .idle
        default:
            break
        }
    }
}
