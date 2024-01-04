//
//  FeedListViewController.swift
//  RSSFeed
//
//  Created by Mirko Braic on 25.12.2023..
//

import UIKit
import SnapKit
import Then
import Combine

class FeedListViewController: UIViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<String, RssFeed.ID>
    typealias Snapshot = NSDiffableDataSourceSnapshot<String, RssFeed.ID>

    private let noFeedsLabel = UILabel().then {
        $0.text = "No RSS feeds added."
        $0.isHidden = true
        $0.textAlignment = .center
        $0.textColor = .secondaryLabel
        $0.font = UIFont.preferredFont(forTextStyle: .title3)
    }
    private let addFeedButton = UIButton(type: .system).then {
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .rsTint
        config.title = "New RSS feed"
        config.image = UIImage(systemName: "plus.circle.fill")
        config.imagePadding = 5
        $0.configuration = config
    }
    private let activityIndicator = UIActivityIndicatorView()
    private var collectionView: UICollectionView! //(frame: .zero, collectionViewLayout: CompositionalLayouts.plainList(de))

    private var subscriptions = Set<AnyCancellable>()
    private let input = PassthroughSubject<FeedListViewModel.Input, Never>()
    private var dataSource: DataSource!
    private let viewModel: FeedListViewModel

    init(viewModel: FeedListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: CompositionalLayouts.plainList(swipeActionDelegate: self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        layoutUI()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "RSS Feeds"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.toolbar.barTintColor = .rsBackground

        addFeedButton.addTarget(self, action: #selector(addFeedTapped), for: .touchUpInside)
        collectionView.delegate = self
        collectionView.backgroundColor = .rsBackground

        setupSortMenu()
        initializeDataSource()
        bindToViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = false
        for indexPath in collectionView.indexPathsForSelectedItems ?? [] {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isToolbarHidden = true
    }

    private func bindToViewModel() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())

        output.feedsUpdated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] feeds in
                guard let self else { return }
                noFeedsLabel.isHidden = !feeds.isEmpty
                applySnapshot(for: feeds)
            }
            .store(in: &subscriptions)

        output.loadingData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self else { return }
                if isLoading {
                    noFeedsLabel.isHidden = true
                    activityIndicator.startAnimating()
                } else {
                    activityIndicator.stopAnimating()
                }
            }
            .store(in: &subscriptions)

        output.errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (title, message) in
                guard let self else { return }
                let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { _ in }
                ac.addAction(okAction)
                present(ac, animated: true)
            }
            .store(in: &subscriptions)
    }

    private func setupSortMenu() {
        let defaultSortAction = UIAction(title: "Default", image: nil, state: .on) { [weak self] _ in
            self?.input.send(.toggleSort(.default))
        }
        let favoritesSortAction = UIAction(title: "Favorites", image: UIImage(systemName: "star.fill")) { [weak self] _ in
            self?.input.send(.toggleSort(.favorites))
        }
        switch viewModel.getCurrentSortOrder() {
        case .default:
            defaultSortAction.state = .on
            favoritesSortAction.state = .off
        case .favorites:
            favoritesSortAction.state = .on
            defaultSortAction.state = .off
        }
        let sortMenu = UIMenu(options: .singleSelection, children: [defaultSortAction , favoritesSortAction])
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sort", image: UIImage(systemName: "arrow.up.arrow.down"), menu: sortMenu)
    }

    private func applySnapshot(for feeds: [RssFeed]) {
        var snapshot = Snapshot()
        snapshot.appendSections(["single"])
        snapshot.appendItems(feeds.map { $0.id })
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func deleteFeed(withId id: RssFeed.ID) {
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([id])
        dataSource.apply(snapshot)
        if snapshot.itemIdentifiers.isEmpty {
            noFeedsLabel.isHidden = false
        }
        
        input.send(.deleteFeed(id))
    }

    @objc private func addFeedTapped() {
        input.send(.addFeedTapped)
    }
}

// MARK: - UICollectionViewDelegate
extension FeedListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let id = dataSource.itemIdentifier(for: indexPath) {
            input.send(.feedTapped(id))
        }
    }
}

// MARK: - CollectionViewSwipeActionDelegate
extension FeedListViewController: CollectionViewSwipeActionDelegate {
    func trailingAction(at indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, view, completion in
            guard let self else { return }
            if let id = dataSource.itemIdentifier(for: indexPath) {
                deleteFeed(withId: id)
            }
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }

    func leadingAction(at indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let addToFavorites = UIContextualAction(style: .normal, title: "Favorite") { [weak self] action, view, completion in
            guard let self else { return }
            if let id = dataSource.itemIdentifier(for: indexPath) {
                input.send(.toggleFavorites(id))
            }
            completion(true)
        }
        addToFavorites.backgroundColor = .rsTint
        return UISwipeActionsConfiguration(actions: [addToFavorites])
    }
}

// MARK: - UI Setup
extension FeedListViewController {
    private func layoutUI() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(noFeedsLabel)
        noFeedsLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        navigationController?.toolbar.addSubview(addFeedButton)
        addFeedButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
        }
    }

    private func initializeDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<FeedCell, RssFeed>() { cell, indexPath, rssFeed in
            cell.feed = rssFeed
            cell.favoriteTapCallback = {
                rssFeed.isFavorite.toggle()
                cell.setNeedsUpdateConfiguration()
            }
        }
        dataSource = DataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, rssFeedId in
            let rssFeed = self?.viewModel.getFeed(withId: rssFeedId)
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: rssFeed)
        }
    }
}
