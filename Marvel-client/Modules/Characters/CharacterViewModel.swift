//
//  CharacterViewModel.swift
//  Marvel-client
//
//  Created by Pablo Ezequiel Romero Giovannoni on 05/01/2021.
//

import Foundation

protocol CharacterViewModelFactory {
    func newCharacterViewModel() -> CharacterViewModelProtocol
}

extension DependencyContainer: CharacterViewModelFactory {
    func newCharacterViewModel() -> CharacterViewModelProtocol {
        return CharacterViewModel()
    }
}

protocol CharacterViewModelProtocol {

}

class CharacterViewModel: CharacterViewModelProtocol {


}
