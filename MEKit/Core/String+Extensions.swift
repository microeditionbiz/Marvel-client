//
//  String+Extensions.swift
//  Marvel-client
//
//  Created by Pablo Ezequiel Romero Giovannoni on 05/01/2021.
//

import Foundation
import CryptoKit

extension String {
    var nilIfEmpty: String? {
        return self.isEmpty ? nil : self
    }

    var md5Hash: String {
        let digest = Insecure.MD5.hash(data: self.data(using: .utf8) ?? Data())

        return digest.map {
            String(format: "%02hhx", $0)
        }
        .joined()
    }
}
