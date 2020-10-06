//
//  AccountsProvider.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 30.09.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import Foundation
import CoreData

final class DataProvider<T: NSManagedObject>: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    @Published var data: [T] = []
    
    private let context: NSManagedObjectContext
    private let sortKey: String
    private let ascending: Bool
    private lazy var frc: NSFetchedResultsController<T> = {
        let request = T.fetchRequest() as! NSFetchRequest<T>
        request.sortDescriptors = [NSSortDescriptor(key: sortKey,
                                                    ascending: ascending)]
        context.automaticallyMergesChangesFromParent = true
        return NSFetchedResultsController(fetchRequest: request,
                                          managedObjectContext: context,
                                          sectionNameKeyPath: nil,
                                          cacheName: nil)
    }()
    
    init(persistentContainer: NSPersistentContainer,
         sortKey: String,
         ascending: Bool) {
        context = persistentContainer.viewContext
        self.sortKey = sortKey
        self.ascending = ascending
        super.init()
        frc.delegate = self
        fetch()
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        update()
    }
    
}

private extension DataProvider {
    func fetch() {
        do {
            try frc.performFetch()
            update()
        } catch {
            print("Failed to fetch accounts: \(error)")
        }
    }
    
    func update() {
        data = frc.sections?.first?.objects as? [T] ?? []
    }
}
