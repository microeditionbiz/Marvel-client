//
//  CharactersViewController.swift
//  Marvel-client
//
//  Created by Pablo Ezequiel Romero Giovannoni on 05/01/2021.
//

import UIKit
import Combine

class CharactersViewController: UIViewController, MessagePresenter {

    @IBOutlet weak var tableView: UITableView!
    var dataSource: CharactersListDataSource!

    var cancellables = Set<AnyCancellable>()

    var viewModel: CharactersViewModel!

    var selectCharacterPublisher: AnyPublisher<CharacterViewModel, Never> {
        return selectCharacterSubject.eraseToAnyPublisher()
    }

    fileprivate var selectCharacterSubject = PassthroughSubject<CharacterViewModel, Never>()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Characters", comment: "")

        dataSource = CharactersListDataSource(tableView: tableView)

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: .valueChanged)

        tableView.refreshControl = refreshControl
        tableView.tableFooterView = UIView()

        viewModel.charactersPublisher.sink { [weak self] characters in
            guard let self = self else { return }
            self.dataSource.apply(characters: characters)
        }
        .store(in: &cancellables)

        viewModel.fetch(name: nil) { error in
            guard let error = error else { return }
            self.presentAlert(withError: error)
        }
    }

    @objc func refreshControlAction(_ sender: AnyObject) {
        viewModel.fetch(name: nil) { error in
            self.tableView.refreshControl?.endRefreshing()
        }
    }

}

// MARK: - UITableViewDiffableDataSource

class CharactersListDataSource: UITableViewDiffableDataSource<CharactersListDataSource.Section, CharacterViewModel> {

    enum Section {
        case main
    }

    init(tableView: UITableView) {
        super.init(tableView: tableView) { tableView, indexPath, characterViewModel in
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: CharacterCell.self),
                for: indexPath) as! CharacterCell
            cell.configure(with: characterViewModel)
            return cell
        }
    }

    func apply(characters: [CharacterViewModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CharacterViewModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(characters, toSection: .main)
        self.apply(snapshot)
    }

}

// MARK: - UITableViewDelegate

extension CharactersViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let character = viewModel.character(at: indexPath.row)
        selectCharacterSubject.send(character)
    }

}

