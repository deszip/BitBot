//
//  BuildsNode.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 08.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import Foundation

extension Graph {
    var builds: BuildsNode { BuildsNode(graph: self) }
}

struct BuildsNode {
    
    let graph: Graph
    
    func rebuild(build: BRBuild) {
        graph.dispatch(RebuildCommand(build: build))
    }
    
    func abort(build: BRBuild) {
        graph.dispatch(AbortBuildCommand(build: build))
    }
}
