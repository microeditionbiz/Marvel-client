//
//  MarvelAPI.swift
//  Marvel-client
//
//  Created by Pablo Ezequiel Romero Giovannoni on 05/01/2021.
//

import Foundation

enum MarvelAPI {

    struct Characters: APIEndpoint {
        typealias ResultType = CharactersResponse

        let nameStartsWith: String?
        let offset: Int
        let pageSize: Int

        let path: String = "/characters"

        var queryParameters: [String: Any]? {
            var params = [String: Any]()
            params["offset"] = offset
            params["limit"] = pageSize
            params["orderBy"] = "name"
            nameStartsWith?.nilIfEmpty.do { params["nameStartsWith"] = $0 }
            return params
        }
    }

    struct CharacterComics: APIEndpoint {
        typealias ResultType = CharacterComicsResponseMapping

        let characterId: Int64
        let offset: Int
        let pageSize: Int

        var path: String { "/characters/\(characterId)/comics" }

        var queryParameters: [String: Any]? {
            var params = [String: Any]()
            params["offset"] = offset
            params["limit"] = pageSize
            params["characterId"] = characterId
            params["orderBy"] = "title"
            params["noVariants"] = true
            return params
        }
    }

}
