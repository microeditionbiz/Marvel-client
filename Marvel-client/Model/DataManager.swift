//
//  DataManager.swift
//  Marvel-client
//
//  Created by Pablo Ezequiel Romero Giovannoni on 05/01/2021.
//

import Foundation
import Combine

protocol DataManager {
    func nextOffset(from offset: Int) -> Int
    func fetchCharacters(name: String?, offset: Int) -> AnyPublisher<([Character], Bool), Error>
    func fetchComics(characterID: Int64, offset: Int) -> AnyPublisher<([Comic], Bool), Error>
}

class DataManagerProvider: DataManager {
    typealias Context = HasAPIService & HasCoreDataWrapper & HasNetworkStatus
    private let ctx: Context
    private static let pageSize = 20

    init(context: Context) {
        self.ctx = context
    }

    func nextOffset(from offset: Int) -> Int {
        offset + Self.pageSize
    }

    func fetchCharacters(name: String?, offset: Int) -> AnyPublisher<([Character], Bool), Error> {
        return Future<([Character], Bool), Error> { [weak self] promise in
            guard let self = self else {
                promise(.success(([], false)))
                return
            }

            let endpoint = MarvelAPI.Characters(
                nameStartsWith: name,
                offset: offset,
                pageSize: Self.pageSize
            )

            self.ctx.apiService.load(endpoint: endpoint) { result in
                switch (result, self.ctx.networkStatus.isConnected) {
                case (.failure(let error), true):
                    promise(.failure(error))
                case (.failure, false):
                    fallthrough
                case (.success, _):
                    self.localCharacters(name: name, offset: offset) {
                        promise(.success(($0, $0.count >= offset + Self.pageSize)))
                    }
                }
            }

        }.eraseToAnyPublisher()
    }

    private func localCharacters(name: String?, offset: Int, completion: @escaping ([Character]) -> Void) {
        let predicate = name?
            .nilIfEmpty
            .map { NSPredicate(format: "name BEGINSWITH[c] %@", $0) }

        let sort = NSSortDescriptor(
            key: "name",
            ascending: true,
            selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
        )

        Character.asyncFetchObjects(
            where: predicate,
            sortDescriptors: [sort],
            offset: 0,
            limit: offset + Self.pageSize,
            in: ctx.coreDataWrapper.viewContex,
            completion: {
                completion($0 ?? [])
            }
        )
    }

    func fetchComics(characterID: Int64, offset: Int) -> AnyPublisher<([Comic], Bool), Error> {
        return PassthroughSubject<([Comic], Bool), Error>().eraseToAnyPublisher()
    }

}
