//
//  CoreDataWrapper.swift
//  MEKit
//
//  Created by Pablo Ezequiel Romero Giovannoni on 12/01/2020.
//  Copyright © 2020 Pablo Ezequiel Romero Giovannoni. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataWrapper {
    static var shared: CoreDataWrapperProtocol!
}

public protocol CoreDataWrapperProtocol {
    var containerName: String {get}
    var viewContex: NSManagedObjectContext {get}
    var inMemoryContainer: Bool {get}
    var modelObjectModel: NSManagedObjectModel {get}
      
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void)
    func performAndWaitBackgroundTask(_ block: (NSManagedObjectContext) -> Void)
    func newBackgroundContext() -> NSManagedObjectContext
    func save(context: NSManagedObjectContext)
    
    func batchDelete<T: NSManagedObject>(_ type: T.Type, where predicate: NSPredicate?, in context: NSManagedObjectContext)
    
    func deleteAll()
}

public class CoreDataWrapperProvider: CoreDataWrapperProtocol {
    public static var shared: CoreDataWrapper!
    
    public let containerName: String
    public let inMemoryContainer: Bool
    private let persistentContainer: NSPersistentContainer!
    
    public var modelObjectModel: NSManagedObjectModel {
        return persistentContainer.managedObjectModel
    }

    init(containerName: String, modelName: String? = nil, inMemoryContainer: Bool = false) {
        self.containerName = containerName
        self.inMemoryContainer = inMemoryContainer
   
        var container: NSPersistentContainer!
        
        if let modelName = modelName {
            let fullModelName = "\(modelName).momd/\(modelName).mom"
            let modelURL = Bundle.main.url(forResource: fullModelName, withExtension: nil)!
            let model = NSManagedObjectModel(contentsOf: modelURL)!
            container = NSPersistentContainer(name: containerName, managedObjectModel: model)
        } else {
            container = NSPersistentContainer(name: containerName)
        }
        
        if inMemoryContainer {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                Self.processError(error)
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        self.persistentContainer = container
    }
    
    public var viewContex: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    public func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
    
    public func performAndWaitBackgroundTask(_ block: (NSManagedObjectContext) -> Void) {
        let context = newBackgroundContext()
        context.performAndWait {
            block(context)
        }
    }
    
    public func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    public func save(context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                Self.processError(error)
            }
        }
    }

    // MARK: - delete
    
    public func batchDelete<T: NSManagedObject>(_ type: T.Type, where predicate: NSPredicate?, in context: NSManagedObjectContext) {
        let fetchRequest = type.fetchRequest(resultOf: NSFetchRequestResult.self, where: predicate)
        let deleteFetchRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteFetchRequest.resultType = .resultTypeObjectIDs
        
        do {
            let result = try persistentContainer.persistentStoreCoordinator.execute(deleteFetchRequest, with: context) as? NSBatchDeleteResult
            
            if viewContex !== context {
                guard let objectIDs = result?.result as? [NSManagedObjectID] else { return }
                let changes = [NSDeletedObjectsKey: objectIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [viewContex])
            }
        } catch {
            fatalError("Failed to execute request: \(error)")
        }
    }
    
    public func deleteAll() {
        persistentContainer.persistentStoreDescriptions.forEach { description in
            if let url = description.url {
                try? persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: NSSQLiteStoreType, options: nil)
            }
        }
    }
    
    fileprivate static func processError(_ error: Error) {
        let nserror = error as NSError
        assertionFailure("Unresolved error \(nserror), \(nserror.userInfo)")
    }
    
}

