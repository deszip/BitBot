//
//  AccountsProvider.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 30.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import Foundation
import CoreData

final class AccountsProvider: NSObject, ObservableObject {
    @Published var accounts: [BTRAccount] = []
    
    private let context: NSManagedObjectContext
    private lazy var frc: NSFetchedResultsController<BTRAccount> = {
        let request = BTRAccount.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "username",
                                                   ascending: true)]
        context.automaticallyMergesChangesFromParent = true
        return NSFetchedResultsController(fetchRequest: request,
                                          managedObjectContext: context,
                                          sectionNameKeyPath: nil,
                                          cacheName: nil)
    }()
    
    init(persistentContainer: NSPersistentContainer) {
        context = persistentContainer.viewContext
        super.init()
        frc.delegate = self
        fetch()
    }
}

extension AccountsProvider: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        update()
    }
}

private extension AccountsProvider {
    func fetch() {
        do {
            try frc.performFetch()
            update()
        } catch {
            print("Failed to fetch accounts: \(error)")
        }
    }
    
    func update() {
        accounts = frc.sections?.first?.objects as? [BTRAccount] ?? []
    }
}
