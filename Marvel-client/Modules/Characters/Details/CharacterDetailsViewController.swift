//
//  CharacterDetailsViewController.swift
//  Marvel-client
//
//  Created by Pablo Ezequiel Romero Giovannoni on 05/01/2021.
//

import UIKit
import Combine

class CharacterDetailsViewController: UIViewController, MessagePresenter {

    enum Section: String {
        case main
    }

    var viewModel: CharacterDetailsViewModelProtocol!

    var dataSource: UICollectionViewDiffableDataSource<Section, ComicViewModel>!
    var cancellables = Set<AnyCancellable>()
    weak var loadNextPageView: LoadNextPageView?
    @IBOutlet weak var collectionView: UICollectionView!

    static let loadNextPageViewHeight: CGFloat = 44

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.baseDetails.name

        configreDataSource()
        configureCollectionView()
        configureObservables()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    private func configureCollectionView() {
        collectionView.isHidden = false

        collectionView.register(
            CharacterDetailsHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: String(describing: CharacterDetailsHeaderView.self)
        )

        collectionView.register(
            CharacterDetailsFooterView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: String(describing: CharacterDetailsFooterView.self)
        )

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: .valueChanged)

        collectionView.refreshControl = refreshControl
        collectionView.delegate = self

        (collectionView.collectionViewLayout as? ConfigurableFlowLayout).do { layout in
            layout.sectionInset = .init(top: 10, left: 0, bottom: 15, right: 0)
            layout.minimumLineSpacing = 15
            layout.minimumInteritemSpacing = 15
            layout.sectionInsetReference = .fromLayoutMargins
            layout.itemSizeType = .init(
                width: .minColumnWidth(value: 150),
                height: .ratio(value: 1.5)
            )
        }
    }

    private func configreDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, ComicViewModel>(collectionView: collectionView) { collectionView, indexPath, comicViewModel in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: ComicCell.self),
                for: indexPath) as! ComicCell
            cell.configure(with: comicViewModel)
            return cell
        }

        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self = self else { return nil }

            switch kind {
            case UICollectionView.elementKindSectionHeader:
                let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: String(describing: CharacterDetailsHeaderView.self),
                    for: indexPath) as! CharacterDetailsHeaderView
                headerView.configure(with: self.viewModel.baseDetails)
                return headerView
            case UICollectionView.elementKindSectionFooter:
                let footerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: String(describing: CharacterDetailsFooterView.self),
                    for: indexPath) as! CharacterDetailsFooterView
                self.loadNextPageView = footerView.loadNextPageView
                self.loadNextPageView?.isAnimating = self.viewModel.comicsViewModel.canLoadMore
                return footerView
            default:
                return nil
            }
        }
    }

    private func apply(comics: [ComicViewModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ComicViewModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(comics, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: dataSource.snapshot().numberOfItems != 0)
    }

    private func configureObservables() {
        viewModel.comicsViewModel.comicsPublisher
            .sink { [weak self] comics in
                self?.apply(comics: comics)
            }
            .store(in: &cancellables)

        viewModel.comicsViewModel.canLoadMorePublisher
            .removeDuplicates()
            .sink { [weak self] canLoadMore in
                self?.loadNextPageView?.isAnimating = canLoadMore
            }
            .store(in: &cancellables)

        viewModel.comicsViewModel.fetch { [weak self] error in
            error.do { self?.presentAlert(withError: $0) }
        }
    }

    @objc func refreshControlAction(_ sender: AnyObject) {
        viewModel.comicsViewModel.fetch { [weak self] _ in
            DispatchQueue.main.async {
                self?.collectionView.refreshControl?.endRefreshing()
            }
        }
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension CharacterDetailsViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let comic = viewModel.comicsViewModel.comic(at: indexPath.item)
        print("Selected \(comic.title)")
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 500.0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: Self.loadNextPageViewHeight)
    }

}

// MARK: - UIScrollViewDelegate

extension CharacterDetailsViewController: UIScrollViewDelegate {

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewDidEndScrolling(scrollView)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScrolling(scrollView)
    }

    func scrollViewDidEndScrolling(_ scrollView: UIScrollView) {
        if viewModel.comicsViewModel.canLoadMore {
            let visibleHeight = scrollView.frame.size.height - scrollView.contentInset.bottom

            let isLoadNextPageAreaVisible = visibleHeight >= (scrollView.contentSize.height - Self.loadNextPageViewHeight - scrollView.contentOffset.y)

            if isLoadNextPageAreaVisible {
                viewModel.comicsViewModel.fetchNextPage(completion: nil)
            }
        }
    }

}
