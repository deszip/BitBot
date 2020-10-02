//
//  AccountView.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 01.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct AccountView: View {
    
    let imageURL: URL?
    let userName: String
    let email: String
    
    var body: some View {
        Button(action: {
            //do smth
        }) {
            HStack {
                AsyncImage(url: imageURL)
                    .placeholder(.defaultAvatar)
                    .resizable()
                    .frame(width: 180, height: 180)
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(20)
                VStack(alignment: .leading) {
                    Text(userName)
                    Text(email)
                }
            }
        }
        .frame(height: 200)
        .contextMenu {
            Button("Delete account".localized()) {
                //delete acc
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView(imageURL: nil,
                    userName: "vladislavsosiuk",
                    email: "vladislavsosiuk@gmail.com")
    }
}
