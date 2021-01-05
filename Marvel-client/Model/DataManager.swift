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
    func fetchCharacters(name: String?, offset: Int) -> AnyPublisher<[Character], Error>
    func fetchComics(characterID: Int64, offset: Int) -> AnyPublisher<[Comic], Error>
}

class DataManagerProvider: DataManager {
    typealias Context = HasAPIService & HasCoreDataWrapper
    private let ctx: Context
    private static let pageSize = 20

    init(context: Context) {
        self.ctx = context
    }

    func nextOffset(from offset: Int) -> Int {
        offset + Self.pageSize
    }

    func fetchCharacters(name: String?, offset: Int) -> AnyPublisher<[Character], Error> {
        let subject = PassthroughSubject<[Character], Error>()

        localCharacters(name: name, offset: offset) {
            subject.send($0)
        }

        let endpoint = MarvelAPI.Characters(
            nameStartsWith: name,
            offset: offset,
            pageSize: Self.pageSize
        )

        ctx.apiService.load(endpoint: endpoint) { result in
            switch result {
            case .failure(let error):
                subject.send(completion: .failure(error))
            case .success:
                self.localCharacters(name: name, offset: offset) {
                    subject.send($0)
                    subject.send(completion: .finished)
                }
            }
        }

        return subject.eraseToAnyPublisher()
    }

    private func localCharacters(name: String?, offset: Int, completion: @escaping ([Character]) -> Void) {
        let predicate = name?
            .nilIfEmpty
            .map { NSPredicate(format: "content BEGINSWITH[c] %@", $0) }

        Character.asyncFetchObjects(
            where: predicate,
            sortDescriptors: [NSSortDescriptor(keyPath: \Character.name, ascending: true)],
            offset: 0,
            limit: offset + Self.pageSize,
            in: ctx.coreDataWrapper.viewContex,
            completion: {
                completion($0 ?? [])
            }
        )
    }

    func fetchComics(characterID: Int64, offset: Int) -> AnyPublisher<[Comic], Error> {
        return PassthroughSubject<[Comic], Error>().eraseToAnyPublisher()
    }

}
