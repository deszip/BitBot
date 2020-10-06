//
//  BuildView.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 06.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct BuildView: View {
    let userName: String
    let buildNumber: String
    let appName: String
    let branchName: String
    let commitMessage: String
    let workflow: String
    let date: String
    let buildingTime: String
    
    var body: some View {
        Button(action: {}, label: {
            HStack {
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 30)
                VStack(alignment: .leading) {
                    HStack {
                        Text(userName)
                        Spacer()
                        Text(buildNumber)
                    }
                    Text(appName)
                    HStack {
                        Text(branchName)
                        Text(commitMessage)
                        Text(workflow)
                    }
                    HStack {
                        Text(date)
                        Text(buildingTime)
                    }
                }
            }
        })
    }
}

struct BuildView_Previews: PreviewProvider {
    static var previews: some View {
        BuildView(userName: "",
                  buildNumber: "",
                  appName: "",
                  branchName: "",
                  commitMessage: "",
                  workflow: "",
                  date: "",
                  buildingTime: "")
    }
}
