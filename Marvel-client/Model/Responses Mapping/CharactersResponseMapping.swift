//
//  CharactersResponseMapping.swift
//  Marvel-client
//
//  Created by Pablo Ezequiel Romero Giovannoni on 05/01/2021.
//

import Foundation
import CoreData

struct CharactersResponse: APIResponseBase {
    let coreDataWrapper: CoreDataWrapperProtocol = CoreDataWrapper.shared

    init(urlRequest: URLRequest, dataResponse data: Data) throws {
        guard
            let root = try JSONSerialization.jsonObject(with: data) as? Payload,
            let data = root["data"] as? Payload,
            let results = data["results"] as? List  else {
            throw APIServiceError.invalidData(description: "Invalid Characters response")
        }

         coreDataWrapper.performAndWaitBackgroundTask { context in
            results.forEach { characterPayload in
                Character.object(form: characterPayload, in: context)
            }
            self.coreDataWrapper.save(context: context)
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
            self.thumbnail = DataHelper.buildImageURL(payload: thumbnailPayload, variant: "standard_fantastic")
        } else {
            self.thumbnail = nil
        }

        if let imagePayload = dictionary["thumbnail"] as? Payload {
            self.image = DataHelper.buildImageURL(payload: imagePayload)
        } else {
            self.image = nil
        }
    }

}
