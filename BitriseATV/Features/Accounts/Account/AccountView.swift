//
//  AccountView.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 01.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct AccountView: View {
    
    let userName: String
    let email: String
    
    var body: some View {
        Button(action: {
            //do smth
        }) {
            HStack {
                Image(systemName: "pencil")
                VStack(alignment: .leading) {
                    Text(userName)
                    Text(email)
                }
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView(userName: "vladislavsosiuk",
                    email: "vladislavsosiuk@gmail.com")
    }
}
