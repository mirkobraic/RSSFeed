//
//  FeedDetailsViewController.swift
//  RSSFeed
//
//  Created by Mirko Braic on 26.12.2023..
//

import UIKit
import Combine
import Then

class FeedDetailsViewController: UIViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<String, RssItem.ID>
    typealias Snapshot = NSDiffableDataSourceSnapshot<String, RssItem.ID>

    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: CompositionalLayouts.list())
    private let noStoriesLabel = UILabel().then {
        $0.text = "No stories in the current feed."
        $0.isHidden = true
        $0.textAlignment = .center
        $0.textColor = .secondaryLabel
        $0.font = UIFont.preferredFont(forTextStyle: .title3)
    }

    private var subscriptions = Set<AnyCancellable>()
    private let input = PassthroughSubject<FeedDetailsViewModel.Input, Never>()
    private var dataSource: DataSource!
    private let viewModel: FeedDetailsViewModel

    init(viewModel: FeedDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
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
        
        initializeDataSource()
        bindToViewModel()
    }

    private func bindToViewModel() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())

        output.feedUpdated
            .sink { [weak self] feed in
                guard let self, let feed else { return }
                title = feed.title
                noStoriesLabel.isHidden = !feed.items.isEmpty
                applySnapshot(for: feed.items)
            }
            .store(in: &subscriptions)
    }

    private func applySnapshot(for items: [RssItem]) {
        var snapshot = Snapshot()
        snapshot.appendSections(["single"])
        snapshot.appendItems(items.map { $0.id })
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - UICollectionViewDelegate
extension FeedDetailsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let id = dataSource.itemIdentifier(for: indexPath) {
            input.send(.feedItemTapped(id))
        }
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
    }

    private func initializeDataSource() {
        let cellRegistration = CellRegistrations.feedItemListCell()
        dataSource = DataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, rssItemId in
            let rssItem = self?.viewModel.getItem(withId: rssItemId)
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: rssItem)
        }
    }
}
