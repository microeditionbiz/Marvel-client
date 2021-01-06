//
//  ComicsViewModel.swift
//  Marvel-client
//
//  Created by Pablo Ezequiel Romero Giovannoni on 06/01/2021.
//

import Foundation
import Combine

protocol ComicsViewModelFactory {
    func newComicsViewModel(characterId: Int64) -> ComicsViewModel
}

extension DependencyContainer: ComicsViewModelFactory {
    func newComicsViewModel(characterId: Int64) -> ComicsViewModel {
        return ComicsViewModel(context: self, characterId: characterId)
    }
}

typealias ComicsFetchCompletion = (Error?) -> Void

protocol ComicsViewModelProtocol {
    var canLoadMorePublisher: AnyPublisher<Bool, Never> { get }
    var canLoadMore: Bool { get }

    var comicsPublisher: AnyPublisher<[ComicViewModel], Never> { get }
    var comics: [ComicViewModel] { get }
    func comic(at index: Int) -> ComicViewModel

    func fetch(completion: ComicsFetchCompletion?)
    func fetchNextPage(completion: ComicsFetchCompletion?)
}

final class ComicsViewModel: ComicsViewModelProtocol {
    typealias Context = HasDataManager
    private let ctx: Context

    private var currentOffset = 0
    private let currentCharacterId: Int64

    private var comicsSubject = CurrentValueSubject<[ComicViewModel], Never>([])

    var comicsPublisher: AnyPublisher<[ComicViewModel], Never> {
        comicsSubject.eraseToAnyPublisher()
    }

    var comics: [ComicViewModel] {
        comicsSubject.value
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

    init(context: Context, characterId: Int64) {
        self.ctx = context
        self.currentCharacterId = characterId
    }

    func comic(at index: Int) -> ComicViewModel {
        return self.comicsSubject.value[index]
    }

    func fetch(completion: ComicsFetchCompletion?) {
        fetch(
            offset: 0,
            completion: completion
        )
    }

    func fetchNextPage(completion: ComicsFetchCompletion?) {
        guard !isFetchingNextPage else { return }
        isFetchingNextPage = true

        fetch(
            offset: ctx.dataManager.nextOffset(from: self.currentOffset),
            completion: { [weak self] error in
                self?.isFetchingNextPage = false
                completion?(error)
            }
        )
    }

    private func fetch(offset: Int, completion: ComicsFetchCompletion?) {
        ctx.dataManager.fetchCharacterComics(characterId: currentCharacterId, offset: offset)
            .sink(
                receiveCompletion: { [weak self] result in
                    guard let self = self else { return }
                    if case let .failure(error) = result {
                        completion?(error)
                    } else {
                        self.currentOffset = offset
                        completion?(nil)
                    }
                },
                receiveValue: { [weak self] comics, canLoadMore in
                    guard let self = self else { return }
                    canLoadMore.do { self.canLoadMoreSubject.send($0) }
                    comics.do { self.comicsSubject.send($0.map(ComicViewModel.init)) }
                }
            )
            .store(in: &cancellables)
    }

}

// MARK -

struct ComicViewModel {
    let identifier: Int64
    let title: String
    let details: String
    let image: URL?
    let thumbnail: URL?

    init(comic: Comic) {
        self.identifier = comic.identifier
        self.title = comic.title ?? ""
        self.details = comic.details ?? ""
        self.image = comic.image
        self.thumbnail = comic.thumbnail
    }
}

extension ComicViewModel: Hashable {
    static func == (lhs: ComicViewModel, rhs: ComicViewModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

