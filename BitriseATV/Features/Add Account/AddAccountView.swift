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
    @Environment(\.presentationMode) var presentation
    
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
                    //commitTokenAction(accessToken)
                    commitTokenAction("duL7aSsNZUE1YJPl6Zw81shCU2tyTtVQ0mQQkNH9eA-i-VHZ-h_rl3v2VjxaQDSNHfpTqfgYhu9A2UV7VAU5ZA")
                    presentation.wrappedValue.dismiss()
                }
            }
        }
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
