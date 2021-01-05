//
//  NSManagedObject+Extension.swift
//  MEKit
//
//  Created by Pablo Ezequiel Romero Giovannoni on 12/01/2020.
//  Copyright © 2020 Pablo Ezequiel Romero Giovannoni. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    // MARK: - Creation
     
    static func create(in context: NSManagedObjectContext) -> Self {
        return NSEntityDescription.insertNewObject(forEntityName: Self.entityName, into: context) as! Self
    }
    
    static func createTemporary(managedObjectModel: NSManagedObjectModel) -> Self {
       return NSManagedObject(entity: Self.entityDescription(model: managedObjectModel), insertInto: nil) as! Self
    }
    
    // MARK: - Temporary
    
    var isTemporary: Bool {
        return managedObjectContext == nil
    }
    
    // MARK: - Entity metadata
    
    static var entityName: String {
        return String(describing: Self.self)
    }
    
    static func entityDescription(model: NSManagedObjectModel) -> NSEntityDescription {
        return model.entitiesByName[Self.entityName]!
    }
    
    // MARK: - Fetch
    
    static func fetchRequest<Result: NSFetchRequestResult>(resultOf result: Result.Type, where predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, offset: Int = 0, limit: Int? = nil, batchSize: Int? = nil) -> NSFetchRequest<Result> {
        
        let fetchRequest = NSFetchRequest<Result>(entityName: Self.entityName)
        
        // If you have to access all values, it's better to set false
        fetchRequest.returnsObjectsAsFaults = false
        
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        
        if let sortDescriptors = sortDescriptors {
            fetchRequest.sortDescriptors = sortDescriptors
        }
        
        var resultType: NSFetchRequestResultType!

        if result.self is NSManagedObjectID.Type {
            resultType = .managedObjectIDResultType
        } else if result.self is NSNumber.Type {
            resultType = .countResultType
        } else {
            resultType = .managedObjectResultType
        }
        
        fetchRequest.fetchOffset = offset
        fetchRequest.resultType = resultType
        
        if let limit = limit {
            fetchRequest.fetchLimit = limit
        }
        
        if let batchSize = batchSize {
            fetchRequest.fetchBatchSize = batchSize
        }
        
        return fetchRequest
    }
    
    static func fetchObject(where predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, in context: NSManagedObjectContext) -> Self? {
          
        let fetchRequest = Self.fetchRequest(resultOf: Self.self, where: predicate, sortDescriptors: sortDescriptors, limit: 1)
          
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            let nserror = error as NSError
            assertionFailure("Unresolved error \(nserror), \(nserror.userInfo)")
            return nil
        }
    }
    
    static func fetchObjects<T: NSManagedObject>(_ type: T.Type, where predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, offset: Int = 0, limit: Int? = nil, batchSize: Int? = nil, in context: NSManagedObjectContext) -> [T] {
        
        let fetchRequest = Self.fetchRequest(resultOf: Self.self, where: predicate, sortDescriptors: sortDescriptors, offset: offset, limit: limit, batchSize: batchSize)
        
        do {
            return try context.fetch(fetchRequest) as? [T] ?? []
        } catch {
            let nserror = error as NSError
            assertionFailure("Unresolved error \(nserror), \(nserror.userInfo)")
            return []
        }
    }
    
    static func fetchObjects<T: NSManagedObject>(_ type: T.Type, withObjectIDs objectIDs: [NSManagedObjectID], in context: NSManagedObjectContext) -> [T] {
        return objectIDs.compactMap { objectID in
            return context.object(with: objectID) as? T
        }
    }
      
    @discardableResult
    static func asyncFetchObject(where predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, in context: NSManagedObjectContext, completion: @escaping (Self?)->()) -> NSPersistentStoreAsynchronousResult? {
          
        let fetchRequest = Self.fetchRequest(resultOf: Self.self, where: predicate, sortDescriptors: sortDescriptors, limit: 1)
          
        let asyncFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { result in
            completion(result.finalResult?.first)
        }
        
        do {
            return try context.execute(asyncFetchRequest) as? NSPersistentStoreAsynchronousResult
        } catch {
            let nserror = error as NSError
            assertionFailure("Unresolved error \(nserror), \(nserror.userInfo)")
              return nil
        }
    }
      
    @discardableResult
    static func asyncFetchObjects<T: NSManagedObject>(_ type: T.Type, where predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, offset: Int = 0, limit: Int? = nil, batchSize: Int? = nil, in context: NSManagedObjectContext, completion: @escaping ([T]?)->()) -> NSPersistentStoreAsynchronousResult? {
          
        let fetchRequest = Self.fetchRequest(resultOf: Self.self, where: predicate, sortDescriptors: sortDescriptors, offset: offset, limit: limit, batchSize: batchSize)
        
        let asyncFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { result in
            completion(result.finalResult as? [T])
        }
          
        do {
            return try context.execute(asyncFetchRequest) as? NSPersistentStoreAsynchronousResult
        } catch {
            let nserror = error as NSError
            assertionFailure("Unresolved error \(nserror), \(nserror.userInfo)")
            return nil
        }
    }
    
    static func count(where predicate: NSPredicate? = nil, in context: NSManagedObjectContext) -> Int {
          
        let fetchRequest = Self.fetchRequest(resultOf: NSNumber.self, where: predicate)
        
        do {
            return try context.count(for: fetchRequest)
        } catch {
            let nserror = error as NSError
            assertionFailure("Unresolved error \(nserror), \(nserror.userInfo)")
            return 0
        }
    }

    static func exist(where predicate: NSPredicate?, in context: NSManagedObjectContext) -> Bool {
        
        let fetchRequest = Self.fetchRequest(resultOf: NSManagedObjectID.self, where: predicate, limit: 1)
        
        do {
            return try !context.fetch(fetchRequest).isEmpty
        } catch {
            let nserror = error as NSError
            assertionFailure("Unresolved error \(nserror), \(nserror.userInfo)")
            return false
        }
    }
      
    static func isEmpty(in context: NSManagedObjectContext) -> Bool {
        return !Self.exist(where: nil, in: context)
    }
    
    // MARK: - Delete

    static func delete(where predicate: NSPredicate? = nil, in context: NSManagedObjectContext) {
        Self.fetchObjects(Self.self, where: predicate, in: context).forEach({ $0.delete() })
    }
    
    func delete() {
        guard let context = managedObjectContext else {
            assertionFailure("Not defined context")
            return
        }
        
        context.delete(self)
    }
    
    // MARK: - Change context
    
    func insert(in context: NSManagedObjectContext) {
        context.insert(self)
    }
    
    // MARK: - Save
    
    func save() {
        guard let context = managedObjectContext else {
            assertionFailure("Not defined context")
            return
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            assertionFailure("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
        
}
