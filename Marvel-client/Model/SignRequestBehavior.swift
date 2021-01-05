//
//  SignRequestBehavior.swift
//  Marvel-client
//
//  Created by Pablo Ezequiel Romero Giovannoni on 05/01/2021.
//

import Foundation
import CryptoKit

struct SignRequestBehavior: APIRequestBehavior {
    let publicKey: String
    let privateKey: String

    func before(request: URLRequest) -> URLRequest {
        guard
            let url = request.url,
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        else {
            return request
        }

        var queryItems = urlComponents.queryItems ?? []

        let timestamp = "\(Date().timeIntervalSince1970)"
        let hash = "\(timestamp)\(privateKey)\(publicKey)".md5Hash

        queryItems.append(URLQueryItem(name: "ts", value: timestamp))
        queryItems.append(URLQueryItem(name: "apikey", value: publicKey))
        queryItems.append(URLQueryItem(name: "hash", value: hash))

        urlComponents.queryItems = queryItems

        return urlComponents.url.map { URLRequest(url: $0) } ?? request
    }
}
