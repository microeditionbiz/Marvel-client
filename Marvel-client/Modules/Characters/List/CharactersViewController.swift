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

    static let loadNextPageViewHeight: CGFloat = 44

    weak var loadNextPageView: LoadNextPageView?
    weak var searchController: UISearchController?
    var pendingRequestWorkItem: DispatchWorkItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Characters", comment: "")

        configureTableView()
        configureLoadNextPageView()
        configureSearch()

        viewModel.charactersPublisher
            .sink { [weak self] characters in
                self?.dataSource.apply(characters: characters)
            }
            .store(in: &cancellables)

        viewModel.canLoadMorePublisher
            .removeDuplicates()
            .sink { [weak self] canLoadMore in
                self?.loadNextPageView?.isAnimating = canLoadMore
            }
            .store(in: &cancellables)

        viewModel.fetch { [weak self] error in
            guard let error = error else { return }
            self?.presentAlert(withError: error)
        }
    }

    private func configureTableView() {
        dataSource = CharactersListDataSource(tableView: tableView)

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: .valueChanged)

        tableView.refreshControl = refreshControl
        tableView.tableFooterView = UIView()
        tableView.delegate = self
    }

    private func configureSearch() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Characters"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        self.searchController = searchController
    }

    private func configureLoadNextPageView() {
        let loadNextPageView = LoadNextPageView(
            frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: Self.loadNextPageViewHeight)
        )
        tableView.tableFooterView = loadNextPageView
        loadNextPageView.isAnimating = true
        self.loadNextPageView = loadNextPageView
    }


    @objc func refreshControlAction(_ sender: AnyObject) {
        viewModel.fetch(
            name: self.searchController?.searchBar.text?.nilIfEmpty,
            forceUpdate: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.refreshControl?.endRefreshing()
            }
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

// MARK: - UIScrollViewDelegate

extension CharactersViewController: UIScrollViewDelegate {

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewDidEndScrolling(scrollView)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScrolling(scrollView)
    }

    func scrollViewDidEndScrolling(_ scrollView: UIScrollView) {
        if viewModel.canLoadMore {
            let visibleHeight = scrollView.frame.size.height - scrollView.contentInset.bottom

            let isLoadNextPageAreaVisible = visibleHeight >= (scrollView.contentSize.height - Self.loadNextPageViewHeight - scrollView.contentOffset.y)

            if isLoadNextPageAreaVisible {
                viewModel.fetchNextPage(completion: nil)
            }
        }
    }

}

// MARK: - UISearchResultsUpdating

extension CharactersViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        pendingRequestWorkItem?.cancel()

        // Wrap our request in a work item
        let requestWorkItem = DispatchWorkItem { [weak self] in
            self?.viewModel.fetch(
                name: searchController.searchBar.text?.nilIfEmpty,
                forceUpdate: false) { error in
                guard let error = error else { return }
                self?.presentAlert(withError: error)
            }
        }

        // Save the new work item and execute it after 500 ms
        pendingRequestWorkItem = requestWorkItem
        DispatchQueue.main.asyncAfter(
            deadline: .now() + .milliseconds(500),
            execute: requestWorkItem
        )
    }

}
