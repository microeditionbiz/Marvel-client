//
//  NetworkStatus.swift
//  Marvel-client
//
//  Created by Pablo Ezequiel Romero Giovannoni on 06/01/2021.
//

import Foundation
import Combine
import Network


protocol NetworkStatus {
    var connectedPublisher: AnyPublisher<Bool, Never> { get }
    var isConnected: Bool { get }
}

extension NWPath.Status {
    var isConnected: Bool {
        switch self {
        case .unsatisfied, .requiresConnection:
            return false
        case .satisfied:
            return true
        @unknown default:
            return true
        }
    }
}

class NetworkStatusProvider: NetworkStatus {
    private let monitor = NWPathMonitor()
    private let connectedSubject = PassthroughSubject<Bool, Never>()

    var connectedPublisher: AnyPublisher<Bool, Never> {
        return connectedSubject.eraseToAnyPublisher()
    }

    var isConnected: Bool = true {
        didSet {
            connectedSubject.send(isConnected)
        }
    }

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status.isConnected
        }
        monitor.start(queue: DispatchQueue.main)
    }

}
