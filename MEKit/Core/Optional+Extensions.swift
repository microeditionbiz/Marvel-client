//
//  Optional+Extensions.swift
//  Marvel-client
//
//  Created by Pablo Ezequiel Romero Giovannoni on 05/01/2021.
//

import Foundation

extension Optional {
    func `do`(_ task: (Wrapped) -> Void, otherwise: (() -> Void)? = nil) {
        guard let self = self else {
            otherwise?()
            return
        }
        task(self)
    }
}
