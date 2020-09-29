//
//  DependencyContainer.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 29.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import Foundation

final class DependencyContainer {
    private let persistentContainer: NSPersistentContainer
    
    init() {
        persistentContainer = BRContainerBuilder().buildContainer()
    }
    
    func accountsObserver() -> BRAccountsObserver {
        BRAccountsObserver(container: persistentContainer)
    }
}
