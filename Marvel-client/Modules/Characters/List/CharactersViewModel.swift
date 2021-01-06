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
    var canLoadMorePublisher: AnyPublisher<Bool, Never> { get }
    var canLoadMore: Bool { get }

    var charactersPublisher: AnyPublisher<[CharacterViewModel], Never> { get }
    func character(at index: Int) -> CharacterViewModel

    func fetch(completion: CharactersFetchCompletion?)
    func fetch(name: String?, forceUpdate: Bool, completion: CharactersFetchCompletion?)
    func fetchNextPage(completion: CharactersFetchCompletion?)
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

    private var canLoadMoreSubject = CurrentValueSubject<Bool, Never>(true)
    var canLoadMorePublisher: AnyPublisher<Bool, Never> {
        canLoadMoreSubject.eraseToAnyPublisher()
    }

    var canLoadMore: Bool {
        canLoadMoreSubject.value
    }

    private var isFetchingNextPage = false

    private var cancellables = Set<AnyCancellable>()

    init(context: Context) {
        self.ctx = context
    }

    func character(at index: Int) -> CharacterViewModel {
        return self.charactersSubject.value[index]
    }

    func fetch(completion: CharactersFetchCompletion?) {
        fetch(
            name: nil,
            offset: 0,
            completion: completion
        )
    }

    func fetch(name: String?, forceUpdate: Bool, completion: CharactersFetchCompletion?) {
        if !forceUpdate && name == self.currentName {
            completion?(nil)
        } else {
            fetch(
                name: name,
                offset: 0,
                completion: completion
            )
        }
    }

    func fetchNextPage(completion: CharactersFetchCompletion?) {
        guard !isFetchingNextPage else { return }
        isFetchingNextPage = true

        fetch(
            name: currentName,
            offset: ctx.dataManager.nextOffset(from: self.currentOffset),
            completion: { [weak self] error in
                self?.isFetchingNextPage = false
                completion?(error)
            }
        )
    }

    private func fetch(name: String?, offset: Int, completion: CharactersFetchCompletion?) {
        ctx.dataManager.fetchCharacters(name: name, offset: offset)
            .sink(
                receiveCompletion: { [weak self] result in
                    guard let self = self else { return }
                    if case let .failure(error) = result {
                        completion?(error)
                    } else {
                        self.currentOffset = offset
                        self.currentName = name
                        completion?(nil)
                    }
                },
                receiveValue: { [weak self] characters, canLoadMore in
                    guard let self = self else { return }
                    self.canLoadMoreSubject.send(canLoadMore)
                    self.charactersSubject.send(characters.map(CharacterViewModel.init))
                }
            )
            .store(in: &cancellables)
    }
    
}

// MARK -

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
