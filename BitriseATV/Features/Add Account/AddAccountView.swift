//
//  AddAccountView.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 29.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct AddAccountView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var accessToken: String = ""
    
    let commitTokenAction: (String) -> Void
    
    var body: some View {
        VStack {
            Text("We know it is inconvenient to enter token with Siri Remote. Please use the Remote app on your iPhone to simply paste the token.".localized())
                .proximaFont(size: 43, weight: .regular)
                .foregroundColor(.BBBuildTintColor)
            FocusSupportingTextField(placeholder: "Enter personal access token".localized(),
                                     text: $accessToken,
                                     keyboardType: .asciiCapable,
                                     font: .proxima(weight: .regular, size: 43)) { focused in
                return UIColor.secondaryText.resolvedColor(for: colorScheme, focused: focused)
            } onCommit: {
                if !accessToken.isEmpty {
                    commitTokenAction(accessToken)
                }
            }
        }
//            .onAppear {
//                commitTokenAction("")
//            }
    }
}

struct AddAccount_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AddAccountView(commitTokenAction: { _ in })
                .preferredColorScheme(.light)
            AddAccountView(commitTokenAction: { _ in })
                .preferredColorScheme(.light)
        }
    }
}
