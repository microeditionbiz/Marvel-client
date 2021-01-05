//  FileSystemHelper.swift
//  MEKit
//
//  Created by Pablo Ezequiel Romero Giovannoni on 23/11/2019.
//  Copyright © 2019 Pablo Ezequiel Romero Giovannoni. All rights reserved.
//

import UIKit

class FileSystemHelper {
    fileprivate static let fileManager = FileManager.default
    
    static func existFile(at url: URL) -> Bool {
        let path = url.path
        return Self.fileManager.fileExists(atPath: path)
    }
    
    static func removeFile(at fileURL: URL) throws {
        if FileSystemHelper.existFile(at: fileURL) {
            try Self.fileManager.removeItem(at: fileURL)
        }
    }
    
    static func copyFile(at initialUrl: URL, to finalURL: URL) throws {
        try Self.removeFile(at: finalURL)
        try Self.fileManager.copyItem(at: initialUrl, to: finalURL)
    }
    
    static func cachesUrl() -> URL {
        return fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    static func directoryURL() -> URL {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
