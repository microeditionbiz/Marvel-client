//
//  CharacterDetailsViewModel.swift
//  Marvel-client
//
//  Created by Pablo Ezequiel Romero Giovannoni on 05/01/2021.
//

import Foundation

protocol CharacterDetailsViewModelFactory {
    func newCharacterDetailsViewModel(character: CharacterViewModel) -> CharacterDetailsViewModelProtocol
}

extension DependencyContainer: CharacterDetailsViewModelFactory {
    func newCharacterDetailsViewModel(character: CharacterViewModel) -> CharacterDetailsViewModelProtocol {
        let comicsViewModel = self.newComicsViewModel(characterId: character.identifier)
        return CharacterDetailsViewModel(character: character, comics: comicsViewModel)
    }
}

typealias CharactersDetailsFetchCompletion = (Error?) -> Void

protocol CharacterDetailsViewModelProtocol {
    var baseDetails: CharacterViewModel { get }
    var comicsViewModel: ComicsViewModelProtocol { get }
}

class CharacterDetailsViewModel: CharacterDetailsViewModelProtocol {
    let baseDetails: CharacterViewModel
    let comicsViewModel: ComicsViewModelProtocol

    init(character: CharacterViewModel, comics: ComicsViewModelProtocol) {
        self.baseDetails = character
        self.comicsViewModel = comics
    }
}
