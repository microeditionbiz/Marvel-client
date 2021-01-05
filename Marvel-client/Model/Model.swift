// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import CoreData
import Foundation


// MARK: - Character

@objc(Character)
internal class Character: NSManagedObject {

    @nonobjc internal static func fetchRequest(where predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, offset: Int = 0, limit: Int? = nil, batchSize: Int? = nil) -> NSFetchRequest<Character> {
        return Self.fetchRequest(resultOf: Character.self, where: predicate, sortDescriptors: sortDescriptors, offset: offset, limit: limit, batchSize: batchSize)
    }

    @nonobjc internal static func fetchObjects(where predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, offset: Int = 0, limit: Int? = nil, batchSize: Int? = nil, in context: NSManagedObjectContext) -> [Character] {
        return Self.fetchObjects(Character.self, where: predicate, sortDescriptors: sortDescriptors, offset: offset, limit: limit, batchSize: batchSize, in: context)
    }

    @discardableResult @nonobjc internal static func asyncFetchObjects(where predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, offset: Int = 0, limit: Int? = nil, batchSize: Int? = nil, in context: NSManagedObjectContext, completion: @escaping ([Character]?)->()) -> NSPersistentStoreAsynchronousResult? {
        return Self.asyncFetchObjects(Character.self, where: predicate, sortDescriptors: sortDescriptors, offset: offset, limit: limit, batchSize: batchSize, in: context, completion: completion)
    }

    @discardableResult @nonobjc internal static func fetchObjects(withObjectIDs objectIDs: [NSManagedObjectID], in context: NSManagedObjectContext) -> [Character] {
        return Self.fetchObjects(Character.self, withObjectIDs: objectIDs, in: context)
    }

    @NSManaged internal var details: String?
    @NSManaged internal var identifier: Int64
    @NSManaged internal var image: URL?
    @NSManaged internal var name: String?
    @NSManaged internal var thumbnail: URL?
    @NSManaged internal var comics: Set<Comic>?
}

// MARK: Relationship Comics

extension Character {
    @objc(addComicsObject:)
    @NSManaged public func addToComics(_ value: Comic)

    @objc(removeComicsObject:)
    @NSManaged public func removeFromComics(_ value: Comic)

    @objc(addComics:)
    @NSManaged public func addToComics(_ values: Set<Comic>)

    @objc(removeComics:)
    @NSManaged public func removeFromComics(_ values: Set<Comic>)
}

// MARK: - Comic

@objc(Comic)
internal class Comic: NSManagedObject {

    @nonobjc internal static func fetchRequest(where predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, offset: Int = 0, limit: Int? = nil, batchSize: Int? = nil) -> NSFetchRequest<Comic> {
        return Self.fetchRequest(resultOf: Comic.self, where: predicate, sortDescriptors: sortDescriptors, offset: offset, limit: limit, batchSize: batchSize)
    }

    @nonobjc internal static func fetchObjects(where predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, offset: Int = 0, limit: Int? = nil, batchSize: Int? = nil, in context: NSManagedObjectContext) -> [Comic] {
        return Self.fetchObjects(Comic.self, where: predicate, sortDescriptors: sortDescriptors, offset: offset, limit: limit, batchSize: batchSize, in: context)
    }

    @discardableResult @nonobjc internal static func asyncFetchObjects(where predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, offset: Int = 0, limit: Int? = nil, batchSize: Int? = nil, in context: NSManagedObjectContext, completion: @escaping ([Comic]?)->()) -> NSPersistentStoreAsynchronousResult? {
        return Self.asyncFetchObjects(Comic.self, where: predicate, sortDescriptors: sortDescriptors, offset: offset, limit: limit, batchSize: batchSize, in: context, completion: completion)
    }

    @discardableResult @nonobjc internal static func fetchObjects(withObjectIDs objectIDs: [NSManagedObjectID], in context: NSManagedObjectContext) -> [Comic] {
        return Self.fetchObjects(Comic.self, withObjectIDs: objectIDs, in: context)
    }

    @NSManaged internal var details: String?
    internal var identifier: Int64? {
        get {
            let key = "identifier"
            willAccessValue(forKey: key)
            defer { didAccessValue(forKey: key) }

            return primitiveValue(forKey: key) as? Int64
        }
        set {
            let key = "identifier"
            willChangeValue(forKey: key)
            defer { didChangeValue(forKey: key) }

        setPrimitiveValue(newValue, forKey: key)
        }
    }
    @NSManaged internal var image: URL?
    @NSManaged internal var thumbnail: URL?
    @NSManaged internal var title: String?
    @NSManaged internal var characters: Set<Character>?
}

// MARK: Relationship Characters

extension Comic {
    @objc(addCharactersObject:)
    @NSManaged public func addToCharacters(_ value: Character)

    @objc(removeCharactersObject:)
    @NSManaged public func removeFromCharacters(_ value: Character)

    @objc(addCharacters:)
    @NSManaged public func addToCharacters(_ values: Set<Character>)

    @objc(removeCharacters:)
    @NSManaged public func removeFromCharacters(_ values: Set<Character>)
}

