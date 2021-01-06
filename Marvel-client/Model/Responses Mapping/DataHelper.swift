//
//  DataHelper.swift
//  Marvel-client
//
//  Created by Pablo Ezequiel Romero Giovannoni on 06/01/2021.
//

import Foundation

enum DataHelper {
    
    static func buildImageURL(payload: [String: Any], variant: String? = nil) -> URL? {
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
