//
//  CharactersCoordinator.swift
//  Marvel-client
//
//  Created by Pablo Ezequiel Romero Giovannoni on 05/01/2021.
//

import UIKit
import Combine

protocol CharactersCoordinatorFactory {
    func newCharactersCoordinator(splitViewController: UISplitViewController) -> CharactersCoordinator
}

extension DependencyContainer: CharactersCoordinatorFactory {
    func newCharactersCoordinator(splitViewController: UISplitViewController) -> CharactersCoordinator {
        return CharactersCoordinator(context: self, splitViewController: splitViewController)
    }
}

final class CharactersCoordinator: Coordinator {
    typealias Context = CharactersViewModelFactory & CharacterDetailsViewModelFactory
    let ctx: Context
    unowned let splitViewController: UISplitViewController
    private var cancellables = Set<AnyCancellable>()

    init(context: Context, splitViewController: UISplitViewController) {
        self.ctx = context
        self.splitViewController = splitViewController
    }

    func start(animated: Bool) {
        showCharacters(animated: animated)
    }

    private func showCharacters(animated: Bool) {
        self.splitViewController.delegate = self

        self.splitViewController.viewControllers = [
            creataCharactersVC(),
            createCharacterNotSelectedVC()
        ]
        .map(UINavigationController.init)

        self.splitViewController.preferredDisplayMode = .allVisible
    }

    func showCharacterDetails(characterViewModel: CharacterViewModel) {
        let vc = createCharacterVC(with: characterViewModel)
        splitViewController.showDetailViewController(UINavigationController(rootViewController: vc), sender: self)
    }

    private func creataCharactersVC() -> CharactersViewController {
        let vc = Storyboards.characters.createViewController(of: CharactersViewController.self)
        vc.viewModel = ctx.newCharactersViewModel()
        vc.selectCharacterPublisher
            .sink { [weak self] characterViewModel in
                self?.showCharacterDetails(characterViewModel: characterViewModel)
            }
            .store(in: &cancellables)
        return vc
    }

    private func createCharacterVC(with viewModel: CharacterViewModel) -> CharacterDetailsViewController {
        let vc = Storyboards.characters.createViewController(of: CharacterDetailsViewController.self)
        vc.viewModel = ctx.newCharacterDetailsViewModel(character: viewModel)
        vc.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        vc.navigationItem.leftItemsSupplementBackButton = true
        return vc
    }

    private func createCharacterNotSelectedVC() -> CharacterNotSelectedViewController {
        let vc = Storyboards.characters.createViewController(of: CharacterNotSelectedViewController.self)
        vc.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        vc.navigationItem.leftItemsSupplementBackButton = true
        return vc
    }

}


// MARK: -

extension CharactersCoordinator: UISplitViewControllerDelegate {

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        guard let navController = secondaryViewController as? UINavigationController, let _ = navController.topViewController as? CharacterNotSelectedViewController else {
            return false
        }
        return true
    }

}
