//  URL+sha256Hash.swift
//  MEKit
//
//  Created by Pablo Ezequiel Romero Giovannoni on 23/11/2019.
//  Copyright © 2019 Pablo Ezequiel Romero Giovannoni. All rights reserved.
//

import Foundation
import CryptoKit

extension URL {

    func sha256Hash() -> String {
        let data = Data(self.path.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed
            .compactMap { String(format: "%02x", $0) }
            .joined()
    }
    
}
