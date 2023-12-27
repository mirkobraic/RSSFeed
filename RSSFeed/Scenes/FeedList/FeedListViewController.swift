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
    typealias DataSource = UICollectionViewDiffableDataSource<String, RssFeed>
    typealias Snapshot = NSDiffableDataSourceSnapshot<String, RssFeed>

    private let noFeedsLabel = UILabel().then {
        $0.text = "No RSS feeds added."
        $0.isHidden = true
        $0.textAlignment = .center
        $0.textColor = .secondaryLabel
        $0.font = UIFont.preferredFont(forTextStyle: .title2)
    }
    private let activityIndicator = UIActivityIndicatorView()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: CompositionalLayouts.list)

    private var subscriptions = Set<AnyCancellable>()
    private let input = PassthroughSubject<FeedListViewModel.Input, Never>()
    private var dataSource: DataSource!
    private let viewModel: FeedListViewModel

    init(viewModel: FeedListViewModel) {
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

        title = "RSS Feeds"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFeedTapped))

        collectionView.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: UICollectionViewListCell.defaultReuseIdentifier)
        collectionView.delegate = self

        initializeDataSource()
        bindToViewModel()
    }

    private func bindToViewModel() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())

        output.feedsUpdated
            .sink { [weak self] feeds in
                guard let self else { return }
                noFeedsLabel.isHidden = !feeds.isEmpty
                applySnapshot(for: feeds)
            }
            .store(in: &subscriptions)

        output.loadingData
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
    }

    private func applySnapshot(for feeds: [RssFeed]) {
        var snapshot = Snapshot()
        snapshot.appendSections(["single"])
        snapshot.appendItems(feeds)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    @objc private func addFeedTapped() {
        input.send(.addFeedTapped)
    }
}

// MARK: - UICollectionViewDelegate
extension FeedListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let feed = dataSource.itemIdentifier(for: indexPath) {
            input.send(.feedTapped(feed))
        }
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
    }

    private func initializeDataSource() {
        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, rssFeed in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UICollectionViewListCell.defaultReuseIdentifier, for: indexPath)

            var content = UIListContentConfiguration.cell()
            content.text = rssFeed.title
            cell.contentConfiguration = content

            return cell
        }
    }
}
