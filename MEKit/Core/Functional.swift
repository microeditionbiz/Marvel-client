//
//  Functional.swift
//  Marvel-client
//
//  Created by Pablo Ezequiel Romero Giovannoni on 05/01/2021.
//

import Foundation

func zip<A, B>(_ a: A?, _ b: B?) -> (A, B)? {
    guard let a = a, let b = b else { return nil }
    return (a, b)
}
