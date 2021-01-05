//
//  CharactersViewModel.swift
//  Marvel-client
//
//  Created by Pablo Ezequiel Romero Giovannoni on 05/01/2021.
//

import Foundation

protocol CharactersViewModelFactory {
    func newCharactersViewModel() -> CharactersViewModelProtocol
}

extension DependencyContainer: CharactersViewModelFactory {
    func newCharactersViewModel() -> CharactersViewModelProtocol {
        return CharactersViewModel()
    }
}

protocol CharactersViewModelProtocol {

}

class CharactersViewModel: CharactersViewModelProtocol {


}
