//
//  CharactersViewModel.swift
//  Marvel-client
//
//  Created by Pablo Ezequiel Romero Giovannoni on 05/01/2021.
//

import Foundation
import Combine

protocol CharactersViewModelFactory {
    func newCharactersViewModel() -> CharactersViewModel
}

extension DependencyContainer: CharactersViewModelFactory {
    func newCharactersViewModel() -> CharactersViewModel {
        return CharactersViewModel(context: self)
    }
}

typealias CharactersFetchCompletion = (Error?) -> Void

protocol CharactersViewModelProtocol {
    var canLoadMore: Bool { get }
    var charactersPublisher: AnyPublisher<[CharacterViewModel], Never> { get }

    func character(at index: Int) -> CharacterViewModel
    func fetch(name: String?, completion: @escaping CharactersFetchCompletion)
    func fetchNextPage(completion: @escaping CharactersFetchCompletion)
}

final class CharactersViewModel: CharactersViewModelProtocol {
    typealias Context = HasDataManager
    private let ctx: Context

    private var currentOffset = 0
    private var currentName: String?

    private var charactersSubject = CurrentValueSubject<[CharacterViewModel], Never>([])
    var charactersPublisher: AnyPublisher<[CharacterViewModel], Never> {
        charactersSubject.eraseToAnyPublisher()
    }

    var canLoadMore: Bool = true

    private var cancellables = Set<AnyCancellable>()

    init(context: Context) {
        self.ctx = context
    }

    func character(at index: Int) -> CharacterViewModel {
        return self.charactersSubject.value[index]
    }

    func fetch(name: String?, completion: @escaping CharactersFetchCompletion) {
        fetch(
            name: name,
            offset: 0,
            completion: completion
        )
    }

    func fetchNextPage(completion: @escaping CharactersFetchCompletion) {
        fetch(
            name: currentName,
            offset: ctx.dataManager.nextOffset(from: self.currentOffset),
            completion: completion
        )
    }

    private func fetch(name: String?, offset: Int, completion: @escaping CharactersFetchCompletion) {
        ctx.dataManager.fetchCharacters(name: name, offset: offset)
            .sink(
                receiveCompletion: { [weak self] result in
                    guard let self = self else { return }
                    if case let .failure(error) = result {
                        completion(error)
                    } else {
                        self.currentOffset = offset
                        self.currentName = name
                        completion(nil)
                    }
                },
                receiveValue: { [weak self] characters in
                    self?.charactersSubject.send(characters.map(CharacterViewModel.init))
                }
            )
            .store(in: &cancellables)
    }
    
}

struct CharacterViewModel {
    let identifier: Int64
    let name: String
    let details: String
    let image: URL?
    let thumbnail: URL?

    init(character: Character) {
        self.identifier = character.identifier
        self.name = character.name ?? ""
        self.details = character.details ?? ""
        self.image = character.image
        self.thumbnail = character.thumbnail
    }
}

extension CharacterViewModel: Hashable {
    static func == (lhs: CharacterViewModel, rhs: CharacterViewModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
