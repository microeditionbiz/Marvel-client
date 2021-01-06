//
//  ComicsResponseMapping.swift
//  Marvel-client
//
//  Created by Pablo Ezequiel Romero Giovannoni on 05/01/2021.
//

import Foundation
import CoreData

struct CharacterComicsResponseMapping: APIResponseBase {
    let coreDataWrapper: CoreDataWrapperProtocol = CoreDataWrapper.shared

    init(urlRequest: URLRequest, dataResponse data: Data) throws {
        guard
            let root = try JSONSerialization.jsonObject(with: data) as? Payload,
            let data = root["data"] as? Payload,
            let results = data["results"] as? List  else {
            throw APIServiceError.invalidData(description: "Invalid Comics response")
        }

        coreDataWrapper.performAndWaitBackgroundTask { context in
            let character: Character? =
                self.characterId(from: urlRequest)
                .flatMap { Character.fetchObject(withIDValues: [$0], in: context) }

            results.forEach { comicPayload in
                let comic = Comic.object(form: comicPayload, in: context)

                zip(comic, character)
                    .do { comic, character in
                        character.addToComics(comic)
                    }
            }

            self.coreDataWrapper.save(context: context)
        }
    }

    func characterId(from urlRequest: URLRequest) -> Int64? {
        guard
            let url = urlRequest.url,
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true),
            let queryItems = urlComponents.queryItems,
            let queryItem = queryItems.first(where: { $0.name == "characterId" })
        else {
            return nil
        }

        return queryItem.value.flatMap(Int64.init)
    }
}

extension Comic: NSManagedObjectDictionaryMapping {

    static func objectIDKeys() -> [String] {
        return ["identifier"]
    }

    static func dictionaryIDKeys() -> [String] {
        return ["id"]
    }

    func update(with dictionary: [String: Any]) throws {
        guard let identifier = dictionary["id"] as? Int64 else {
            throw APIServiceError.invalidData(description: "Invalid Comic \(dictionary)")
        }

        self.identifier = identifier
        self.title = dictionary["title"] as? String
        self.details = dictionary["description"] as? String

        if let thumbnailPayload = dictionary["thumbnail"] as? Payload {
            self.thumbnail = DataHelper.buildImageURL(payload: thumbnailPayload, variant: "portrait_incredible")
        } else {
            self.thumbnail = nil
        }

        if let imagePayload = dictionary["image"] as? Payload {
            self.image = DataHelper.buildImageURL(payload: imagePayload)
        } else {
            self.image = nil
        }
    }

}
