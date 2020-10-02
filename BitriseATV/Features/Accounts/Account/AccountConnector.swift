//
//  AccountConnector.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 01.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import SwiftUI

struct AccountConnector: Connector {
    
    let accountViewModel: AccountViewModel
    
    func map(graph: Graph) -> some View {
        AccountView(imageURL: accountViewModel.imageURL,
                    userName: accountViewModel.userName,
                    email: accountViewModel.email)
    }
}
