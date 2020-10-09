//
//  AppConnector.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 09.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct AppConnector: Connector {
    
    let app: BRApp
    
    func map(graph: Graph) -> some View {
        AppView(imageURL: app.avatarURL.flatMap { URL(string: $0) },
                appName: app.title ?? "",
                appRepoURL: app.repoURL ?? "")
    }
}
