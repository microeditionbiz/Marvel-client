//
//  CharactersCoordinator.swift
//  Marvel-client
//
//  Created by Pablo Ezequiel Romero Giovannoni on 05/01/2021.
//

import UIKit

protocol CharactersCoordinatorFactory {
    func newCharactersCoordinator(splitViewController: UISplitViewController) -> CharactersCoordinator
}

extension DependencyContainer: CharactersCoordinatorFactory {
    func newCharactersCoordinator(splitViewController: UISplitViewController) -> CharactersCoordinator {
        return CharactersCoordinator(context: self, splitViewController: splitViewController)
    }
}

final class CharactersCoordinator: Coordinator {
    typealias Context = CharactersViewModelFactory
    let ctx: Context
    unowned let splitViewController: UISplitViewController

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
            creataeCharactersVC(),
            createCharacterVC(with: nil, leftBarButtonItem: splitViewController.displayModeButtonItem, leftItemsSupplementBackButton: true)
            ].map(UINavigationController.init)

        self.splitViewController.preferredDisplayMode = .allVisible
    }

    private func creataeCharactersVC() -> CharactersViewController {
        let vc = Storyboards.characters.createViewController(of: CharactersViewController.self)
        vc.viewModel = ctx.newCharactersViewModel()
//        vc.delegate
        return vc
    }

    private func createCharacterVC(with viewModel: CharacterDetailsViewModelProtocol?, leftBarButtonItem: UIBarButtonItem? = nil, leftItemsSupplementBackButton: Bool? = nil) -> CharacterDetailsViewController {
        let vc = Storyboards.characters.createViewController(of: CharacterDetailsViewController.self)
        vc.viewModel = viewModel
        //        vc.delegate = self

        if let leftBarButtonItem = leftBarButtonItem {
            vc.navigationItem.leftBarButtonItem = leftBarButtonItem
        }

        if let leftItemsSupplementBackButton = leftItemsSupplementBackButton {
            vc.navigationItem.leftItemsSupplementBackButton = leftItemsSupplementBackButton
        }

        return vc
    }

}


// MARK: -

extension CharactersCoordinator: UISplitViewControllerDelegate {

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        guard let navController = secondaryViewController as? UINavigationController, let vc = navController.topViewController as? CharacterDetailsViewController else {
            return false
        }
        return vc.viewModel == nil
    }

}
