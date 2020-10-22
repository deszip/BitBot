//
//  AccountView.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 01.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct AccountView<Destination: View>: View {
    
    let imageURL: URL?
    let userName: String
    let email: String
    
    let deleteAction: () -> Void
    let destination: () -> Destination
    
    var body: some View {
        NavigationLink(destination: destination()) {
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
                .foregroundColor(.BBBuildTintColor)
                .proximaFont(size: 43, weight: .regular)
            }
        }
        .frame(height: 200)
        .contextMenu {
            Button("Delete account".localized()) {
                deleteAction()
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView(imageURL: nil,
                    userName: "vladislavsosiuk",
                    email: "vladislavsosiuk@gmail.com",
                    deleteAction: { },
                    destination: { Text("") })
    }
}
