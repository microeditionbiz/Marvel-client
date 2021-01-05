//
//  CharacterResponseMapping.swift
//  Marvel-client
//
//  Created by Pablo Ezequiel Romero Giovannoni on 05/01/2021.
//

import Foundation
import CoreData

//struct CharacterResponse: APIResponseBase {
//    let coreDataWrapper: CoreDataWrapperProtocol = CoreDataWrapper.shared
//    var managedObjectID: NSManagedObjectID?
//
//    init(_ data: Data) throws {
//        guard let authorPayload = try JSONSerialization.jsonObject(with: data) as? Payload else {
//            throw APIServiceError.invalidData(description: "Invalid Charracter response")
//        }
//
//        coreDataWrapper.performAndWaitBackgroundTask { context in
//            if let managedObject: Author = Author.object(form: authorPayload, in: context) {
//                self.coreDataWrapper.save(context: context)
//                self.managedObjectID = managedObject.objectID
//            }
//        }
//    }
//}

struct CharactersResponse: APIResponseBase {
    let coreDataWrapper: CoreDataWrapperProtocol = CoreDataWrapper.shared
    var managedObjectIDs: [NSManagedObjectID]!

    init(_ data: Data) throws {
        guard
            let root = try JSONSerialization.jsonObject(with: data) as? Payload,
            let data = root["data"] as? Payload,
            let results = data["results"] as? List  else {
            throw APIServiceError.invalidData(description: "Invalid Characters response")
        }

         coreDataWrapper.performAndWaitBackgroundTask { context in
            let managedObjects: [Character] = results.compactMap { characterPayload in
                return Character.object(form: characterPayload, in: context)
            }

            self.coreDataWrapper.save(context: context)
            self.managedObjectIDs = managedObjects.map(\.objectID)
        }
    }
}

extension Character: NSManagedObjectDictionaryMapping {

    static func objectIDKeys() -> [String] {
        return ["identifier"]
    }

    static func dictionaryIDKeys() -> [String] {
        return ["id"]
    }

    func update(with dictionary: [String: Any]) throws {
        guard let identifier = dictionary["id"] as? Int64 else {
            throw APIServiceError.invalidData(description: "Invalid Character \(dictionary)")
        }

        self.identifier = identifier
        self.name = dictionary["name"] as? String
        self.details = dictionary["description"] as? String

        if let thumbnailPayload = dictionary["thumbnail"] as? Payload {
            self.thumbnail = self.buildImageURL(payload: thumbnailPayload, variant: "standard_fantastic")
        } else {
            self.thumbnail = nil
        }

        if let imagePayload = dictionary["image"] as? Payload {
            self.image = self.buildImageURL(payload: imagePayload)
        } else {
            self.image = nil
        }
    }

    private func buildImageURL(payload: [String: Any], variant: String? = nil) -> URL? {
        return zip(
            payload["path"] as? String,
            payload["extension"] as? String
        )
        .flatMap { (path, ext) in
            if let variant = variant, !variant.isEmpty {
                return URL(string: "\(path)/\(variant).\(ext)")
            } else {
                return URL(string: "\(path).\(ext)")
            }
        }
    }

}
