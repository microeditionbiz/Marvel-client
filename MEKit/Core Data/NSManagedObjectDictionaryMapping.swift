//
//  NSManagedObjectDictionaryMapping.swift
//  MEKit
//
//  Created by Pablo Ezequiel Romero Giovannoni on 30/04/2020.
//  Copyright © 2020 Pablo Ezequiel Romero Giovannoni. All rights reserved.
//

import Foundation
import CoreData

protocol NSManagedObjectDictionaryMapping: NSManagedObject {
    static func objectIDKeys() -> [String]
    static func dictionaryIDKeys() -> [String]
    
    func update(with dict: [String: Any]) throws
}

extension NSManagedObjectDictionaryMapping {
    
    @discardableResult
    static func object(form dict: [String: Any], in context: NSManagedObjectContext) -> Self? {
        var managedObject: Self! = Self.fetchObject(withIDValues: dictionaryIDValues(from: dict), in: context)

        if managedObject == nil {
            managedObject = Self.create(in: context)
            do {
                try managedObject.update(with: dict)
                return managedObject
            } catch {
                managedObject.delete()
                print(error)
                return nil
            }
        } else {
            do {
                try managedObject.update(with: dict)
            } catch {
                print(error)
            }
            return managedObject
        }
    }
    
    static func fetchObject(withIDValues IDValues: [Any], in context: NSManagedObjectContext) -> Self? {

        let objectIDKeys = Self.objectIDKeys()
        assert(IDValues.count == objectIDKeys.count, "The number of values has to match with the number of ids")
        
        var predicateString = ""
        
        for (index, IDKey) in objectIDKeys.enumerated() {
            if !predicateString.isEmpty {
                predicateString += " AND "
            }
            
            let value = IDValues[index];
            
            if let stringValue = value as? String {
                predicateString = predicateString.appendingFormat("%@ == '%@'", IDKey, stringValue)
            } else {
                predicateString = predicateString.appendingFormat("%@ == \(value)", IDKey)
            }
        }
        
        return Self.fetchObject(where: NSPredicate(format: predicateString), in: context)
    }
    
    var objectIDValues: [Any] {
        return Self.objectIDKeys().compactMap {
            return self.value(forKey: $0)
        }
    }
    
    static func dictionaryIDValues(from dict: [String: Any]) -> [Any] {
        return dictionaryIDKeys().compactMap {
            return dict[$0]
        }
    }
    
}
