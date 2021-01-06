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
    func fetchCharacters(name: String?, offset: Int) -> AnyPublisher<([Character]?, Bool?), Error>
    func fetchCharacterComics(characterId: Int64, offset: Int) -> AnyPublisher<([Comic]?, Bool?), Error>
}

class DataManagerProvider: DataManager {
    typealias Context = HasAPIService & HasCoreDataWrapper & HasNetworkStatus
    private let ctx: Context
    private static let pageSize = 60

    init(context: Context) {
        self.ctx = context
    }

    func nextOffset(from offset: Int) -> Int {
        return offset + Self.pageSize
    }

    func fetchCharacters(name: String?, offset: Int) -> AnyPublisher<([Character]?, Bool?), Error> {
        let subject = CurrentValueSubject<([Character]?, Bool?), Error>((nil, true))

        localCharacters(name: name, offset: offset) { characters in
            subject.send((characters, nil))
        }

        let endpoint = MarvelAPI.Characters(
            nameStartsWith: name,
            offset: offset,
            pageSize: Self.pageSize
        )

        self.ctx.apiService.load(endpoint: endpoint) { result in
            switch (result, self.ctx.networkStatus.isConnected) {
            case (.failure(let error), true):
                subject.send(completion: .failure(error))
            case (.failure, false):
                subject.send(completion: .finished)
            case (.success, _):
                self.localCharacters(name: name, offset: offset) {
                    subject.send((($0, $0.count >= offset + Self.pageSize)))
                    subject.send(completion: .finished)
                }
            }
        }

        return subject.eraseToAnyPublisher()
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

    func fetchCharacterComics(characterId: Int64, offset: Int) -> AnyPublisher<([Comic]?, Bool?), Error> {
        let subject = CurrentValueSubject<([Comic]?, Bool?), Error>((nil, true))

        localCharacterComics(characterId: characterId, offset: offset) { comics in
            subject.send((comics, nil))
        }

        let endpoint = MarvelAPI.CharacterComics(
            characterId: characterId,
            offset: offset,
            pageSize: Self.pageSize
        )

        self.ctx.apiService.load(endpoint: endpoint) { result in
            switch (result, self.ctx.networkStatus.isConnected) {
            case (.failure(let error), true):
                subject.send(completion: .failure(error))
            case (.failure, false):
                subject.send(completion: .finished)
            case (.success, _):
                self.localCharacterComics(characterId: characterId, offset: offset) {
                    print("count \($0.count) >= \(offset + Self.pageSize) value \($0.count >= offset + Self.pageSize)")
                    subject.send((($0, $0.count >= offset + Self.pageSize)))
                    subject.send(completion: .finished)
                }
            }
        }

        return subject.eraseToAnyPublisher()
    }

    private func localCharacterComics(characterId: Int64, offset: Int, completion: @escaping ([Comic]) -> Void) {
        guard
            let character = Character.fetchObject(withIDValues: [characterId], in: ctx.coreDataWrapper.viewContex),
            let comics = character.comics
        else {
            completion([])
            return
        }

        let sortedComics = comics.sorted { comic1, comic2 -> Bool in
            let result = (comic1.title ?? "")
                .localizedCaseInsensitiveCompare(comic2.title ?? "")
            return result == .orderedAscending
        }
        .prefix(offset + Self.pageSize)

        completion(Array(sortedComics))
    }

}
