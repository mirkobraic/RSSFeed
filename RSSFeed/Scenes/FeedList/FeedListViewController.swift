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
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: CompositionalLayouts.list())

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
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.toolbar.barTintColor = .rsBackground
        navigationItem.rightBarButtonItem = editButtonItem

        addFeedButton.addTarget(self, action: #selector(addFeedTapped), for: .touchUpInside)
        collectionView.delegate = self
        collectionView.backgroundColor = .rsBackground

        initializeDataSource()
        bindToViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isToolbarHidden = true
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
//            applySnapshotForEditing()
        } else {
//            updateSnapshotForViewing()
        }
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

    private func applySnapshot(for feeds: [RssFeed]) {
        var snapshot = Snapshot()
        snapshot.appendSections(["single"])
        snapshot.appendItems(feeds.map { $0.id })
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
        if let id = dataSource.itemIdentifier(for: indexPath) {
            input.send(.feedTapped(id))
        }
    }

    func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        return true
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
        }
        dataSource = DataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, rssFeedId in
            let rssFeed = self?.viewModel.getFeed(withId: rssFeedId)
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: rssFeed)
        }
    }
}
