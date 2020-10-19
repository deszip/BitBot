//
//  RemoteStorageChangesObserver.swift
//  BitBotATV
//
//  Created by Vladislav Sosiuk on 18.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import Foundation

class RemoteStorageChangesObserver {
    
    var persistentContainer: NSPersistentContainer {
        DependencyContainer.shared.persistentContainer()
    }
    
    private let queue = DispatchQueue(label: "RemoteStorageChangesObserverQueue")
    
    func setup() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(remoteStorageDidChange),
                                               name: .NSPersistentStoreRemoteChange,
                                               object: nil)
    }
}

 extension RemoteStorageChangesObserver {
    @objc
    func remoteStorageDidChange() {
        queue.async {
            self.resolveDuplicates()
        }
    }
}

private extension RemoteStorageChangesObserver {
    func resolveDuplicates() {
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: BRBuild.entity().name!)
        
        let slugExpression = NSExpression(forKeyPath: "slug")
        let countExpression = NSExpressionDescription()
        let countVariableExpression = NSExpression(forVariable: "count")
        
        countExpression.name = "count"
        countExpression.expression = NSExpression(forFunction: "count:", arguments: [ slugExpression ])
        countExpression.expressionResultType = .integer32AttributeType
        
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToGroupBy = [BRBuild.entity().propertiesByName["slug"]!]
        fetchRequest.propertiesToFetch = [BRBuild.entity().propertiesByName["slug"]!, countExpression]
        fetchRequest.havingPredicate = NSPredicate(format: "%@ > 1", countVariableExpression)
        let context = persistentContainer.newBackgroundContext()
        context.performAndWait {
            do {
                let duplicates = try context.fetch(fetchRequest)
                delete(duplicateSlugs: duplicates.compactMap { $0["slug"] as? String },
                       performingContext: context)
            } catch {
                print("###\(error)")
            }
        }
    }
    
    func delete(duplicateSlugs: [String], performingContext: NSManagedObjectContext) {
        for slug in duplicateSlugs {
            performingContext.performAndWait {
                let fetchRequest = BRBuild.fetchRequest()
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
                fetchRequest.predicate = NSPredicate(format: "slug == %@", slug)
                guard let duplicateBuilds = try? performingContext.fetch(fetchRequest),
                      duplicateBuilds.count > 1 else { return }
                for duplicateBuild in duplicateBuilds.dropFirst() {
                    performingContext.delete(duplicateBuild)
                }
                try? performingContext.save()
            }
        }
    }
}
