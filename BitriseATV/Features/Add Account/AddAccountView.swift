//
//  AddAccountView.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 29.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct AddAccountView: View {
    
    @State private var accessToken: String = ""
    
    let commitTokenAction: (String) -> Void
    
    var body: some View {
        TextField("Personal access token",
                  text: $accessToken,
                  onCommit: {
                    commitTokenAction(accessToken)
                  })
            .onAppear {
                commitTokenAction("JTg6w3o4jLYz-aGdg5ccKHaRQtMMstYq9W3K7dVeJ_4HJSIN2ms-ziKYiiDxIAbuXEh5UrSohik64A20NbBgdQ")
            }
    }
}

struct AddAccount_Previews: PreviewProvider {
    static var previews: some View {
        AddAccountView(commitTokenAction: { _ in })
    }
}
