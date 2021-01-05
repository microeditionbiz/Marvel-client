//
//  AppCoordinator.swift
//  Marvel-client
//
//  Created by Pablo Ezequiel Romero Giovannoni on 05/01/2021.
//

import UIKit

class AppCoordinator: Coordinator {
    typealias Context = CharactersCoordinatorFactory
    let ctx: Context
    let window: UIWindow
    var characterersCoordinator: CharactersCoordinator!

    init(context: Context, window: UIWindow) {
        self.ctx = context
        self.window = window
    }

    func start(animated: Bool) {
        let splitViewController = UISplitViewController()
        window.rootViewController = splitViewController
        window.makeKeyAndVisible()

        characterersCoordinator = ctx.newCharactersCoordinator(splitViewController: splitViewController)
        characterersCoordinator.start(animated: false)
    }

}
