//
//  CharacterDetailsViewModel.swift
//  Marvel-client
//
//  Created by Pablo Ezequiel Romero Giovannoni on 05/01/2021.
//

import Foundation

protocol CharacterDetailsViewModelFactory {
    func newCharacterDetailsViewModel(character: Character) -> CharacterDetailsViewModelProtocol
}

extension DependencyContainer: CharacterDetailsViewModelFactory {
    func newCharacterDetailsViewModel(character: Character) -> CharacterDetailsViewModelProtocol {
        return CharacterDetailsViewModel(context: self, character: character)
    }
}

protocol CharacterDetailsViewModelProtocol {

}

class CharacterDetailsViewModel: CharacterDetailsViewModelProtocol {
    typealias Context = HasAPIService
    private let ctx: Context

    init(context: Context, character: Character) {
        self.ctx = context
    }

}
