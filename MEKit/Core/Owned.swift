//
//  Owned.swift
//  MEKit
//
//  Created by Pablo Ezequiel Romero Giovannoni on 23/04/2020.
//  Copyright © 2020 Pablo Ezequiel Romero Giovannoni. All rights reserved.
//

import Foundation

struct OwnedKeys {
    static var ownerKey: String = "OwnerKey"
}

protocol Owned: AnyObject {
    var owner: Any? { get set }
}

extension Owned {
    
    var owner: Any? {
        get {
            return objc_getAssociatedObject(self, &OwnedKeys.ownerKey)
        }
        
        set {
            if let currentOwner = objc_getAssociatedObject(self, &OwnedKeys.ownerKey) {
                objc_setAssociatedObject(currentOwner, &OwnedKeys.ownerKey, nil, .OBJC_ASSOCIATION_ASSIGN)
                objc_setAssociatedObject(self, &OwnedKeys.ownerKey, nil, .OBJC_ASSOCIATION_ASSIGN)
            }
            
            if let newValue = newValue {
                objc_setAssociatedObject(newValue, &OwnedKeys.ownerKey, self, .OBJC_ASSOCIATION_RETAIN)
                objc_setAssociatedObject(self, &OwnedKeys.ownerKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
            }
        }
    }
    
}
