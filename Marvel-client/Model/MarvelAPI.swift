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
            nameStartsWith?.nilIfEmpty.do { params["nameStartsWith"] = $0 }
            return params
        }
    }

}
