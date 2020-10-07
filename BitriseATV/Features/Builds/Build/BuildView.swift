//
//  BuildView.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 06.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct BuildView: View {
    let buildColor: Color
    let buildIconImageName: String
    @Binding var rotation: Double
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
            HStack(alignment: .top) {
                ZStack {
                    Rectangle()
                        .fill(buildColor)
                        .frame(width: 75, height: 200)
                        .cornerRadius(8)
                    Image(buildIconImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .rotationEffect(Angle.degrees(rotation))
                        .offset(y: -30)
                }
                VStack(alignment: .leading) {
                    HStack {
                        Text(userName)
                            .foregroundColor(.BBBuildTintColor)
                            .proximaFont(size: 42, weight: .regular)
                        Spacer()
                        Text(buildNumber)
                            .foregroundColor(.BBBuildTintColor)
                            .proximaFont(size: 42, weight: .regular)
                    }
                    Text(appName)
                        .foregroundColor(.white)
                        .proximaFont(size: 60, weight: .regular)
                    HStack {
                        ImageText(imageName: "git-branch",
                                  text: branchName)
                        ImageText(imageName: "message-square",
                                  text: commitMessage)
                        ImageText(imageName: "list",
                                  text: workflow)
                    }
                    HStack {
                        ImageText(imageName: "calendar",
                                  text: date)
                        ImageText(imageName: "clock",
                                  text: buildingTime)
                    }
                }
            }
        })
    }
}

struct BuildView_Previews: PreviewProvider {
    static var previews: some View {
        let binding = Binding<Double>(get: { 0 }, set: { _ in })
        BuildView(buildColor: .BBSuccessColor,
                  buildIconImageName: "0-degree-status-icon",
                  rotation: binding,
                  userName: "vladislav",
                  buildNumber: "100",
                  appName: "bit bot",
                  branchName: "development",
                  commitMessage: "commit",
                  workflow: "deploy",
                  date: "11.10.2020",
                  buildingTime: "10m 20s")
    }
}
