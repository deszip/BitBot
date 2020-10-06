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
                commitTokenAction("jwSkNnInKAs7bxsxhPwwScv3sl9Bql-h28l-AxQpH3ogFHZypfn-c_rpFxBnYQK6br36NdSHj_d_wMUFjv-i7A")
            }
    }
}

struct AddAccount_Previews: PreviewProvider {
    static var previews: some View {
        AddAccountView(commitTokenAction: { _ in })
    }
}
