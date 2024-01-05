//
//  FeedDetailsViewController.swift
//  RSSFeed
//
//  Created by Mirko Braic on 26.12.2023..
//

import UIKit
import Combine
import Then

extension FeedDetailsViewController {
    enum DataSourceItem: Hashable {
        case category(String)
        case feedItem(RssItem.ID)
    }

    enum Sections {
        case categories
        case items
    }
}

class FeedDetailsViewController: UIViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Sections, DataSourceItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Sections, DataSourceItem>

    private let noStoriesLabel = UILabel().then {
        $0.text = "No stories in the current feed."
        $0.isHidden = true
        $0.textAlignment = .center
        $0.textColor = .secondaryLabel
        $0.font = UIFont.preferredFont(forTextStyle: .title3)
    }
    private let activityIndicator = UIActivityIndicatorView()
    private var collectionView: UICollectionView!

    private var subscriptions = Set<AnyCancellable>()
    private let input = PassthroughSubject<FeedDetailsViewModel.Input, Never>()
    var dataSource: DataSource!
    private let viewModel: FeedDetailsViewModel

    init(viewModel: FeedDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout(expandCategories: false))
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

        navigationItem.largeTitleDisplayMode = .never

        collectionView.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: UICollectionViewListCell.defaultReuseIdentifier)
        collectionView.delegate = self
        collectionView.backgroundColor = .rsBackground
        collectionView.allowsMultipleSelection = true

        initializeDataSource()
        bindToViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        for indexPath in collectionView.indexPathsForSelectedItems ?? [] {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }

    private func bindToViewModel() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())

        output.feedUpdated
            .sink { [weak self] feed in
                guard let self, let feed else { return }
                title = feed.title
            }
            .store(in: &subscriptions)

        output.itemsUpdated
            .sink { [weak self] items in
                guard let self else { return }
                noStoriesLabel.isHidden = !items.isEmpty
                applySnapshot(forItems: items)
            }
            .store(in: &subscriptions)

        output.categoriesUpdated
            .sink { [weak self] categories in
                guard let self else { return }
                applySnapshot(forCategories: categories)
            }
            .store(in: &subscriptions)

        output.loadingData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self else { return }
                if isLoading {
                    noStoriesLabel.isHidden = true
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

    private func applySnapshot(forItems items: [RssItem]) {
        var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<DataSourceItem>()
        sectionSnapshot.append(items.map { DataSourceItem.feedItem($0.id) })
        dataSource.apply(sectionSnapshot, to: .items, animatingDifferences: true)
    }

    private func applySnapshot(forCategories categories: [String]) {
        guard categories.isEmpty == false else { return }
        var currentSnapshot = dataSource.snapshot()
        if currentSnapshot.sectionIdentifiers.contains(.categories) {
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<DataSourceItem>()
            sectionSnapshot.append(categories.map { DataSourceItem.category($0) })
            dataSource.apply(sectionSnapshot, to: .categories, animatingDifferences: true)
        } else {
            currentSnapshot.appendSections([.categories])
            currentSnapshot.moveSection(.categories, beforeSection: .items)
            currentSnapshot.appendItems(categories.map { DataSourceItem.category($0) }, toSection: .categories)
            dataSource.apply(currentSnapshot, animatingDifferences: true)
        }
    }
}

// MARK: - UICollectionViewDelegate
extension FeedDetailsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .category(let category):
            input.send(.categoryTapped(category))
        case .feedItem(let id):
            input.send(.feedItemTapped(id))
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath), case .category(let category) = item else { return }
        input.send(.categoryTapped(category))
    }
}

// MARK: UI Setup
extension FeedDetailsViewController {
    private func layoutUI() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(noStoriesLabel)
        noStoriesLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func initializeDataSource() {
        let itemCellRegistration = UICollectionView.CellRegistration<FeedItemCell, RssItem>() { cell, indexPath, rssItem in
            cell.item = rssItem
        }
        let categoryCellRegistration = UICollectionView.CellRegistration<CategoryCell, String>() { cell, indexPath, category in
            cell.label.text = category
        }

        dataSource = DataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, item in
            switch item {
            case .category(let category):
                return collectionView.dequeueConfiguredReusableCell(using: categoryCellRegistration, for: indexPath, item: category)
            case .feedItem(let id):
                let rssItem = self?.viewModel.getItem(withId: id)
                return collectionView.dequeueConfiguredReusableCell(using: itemCellRegistration, for: indexPath, item: rssItem)
            }
        }

        let supplementaryRegistration = UICollectionView.SupplementaryRegistration<CategoryHeader>(elementKind: CategoryHeader.defaultElementKind) { header, elementKid, indexPath in
            header.label.text = "Categories:"
        }
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            return collectionView.dequeueConfiguredReusableSupplementary(using: supplementaryRegistration, for: indexPath)
        }
    }
}
