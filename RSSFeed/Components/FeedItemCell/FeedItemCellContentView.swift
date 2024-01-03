//
//  FeedItemCellContentView.swift
//  RSSFeed
//
//  Created by Mirko Braic on 02.01.2024..
//

import UIKit

class FeedItemCellContentView: UIView, UIContentView {
    private var appliedConfiguration: FeedItemCellContentConfiguration!
    var configuration: UIContentConfiguration {
        get { appliedConfiguration }
        set {
            guard let newConfig = newValue as? FeedItemCellContentConfiguration else { return }
            apply(configuration: newConfig)
        }
    }

    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .bold)
        $0.numberOfLines = 0
    }
    private let descriptionLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12)
        $0.numberOfLines = 0
    }

    init(configuration: FeedItemCellContentConfiguration) {
        super.init(frame: .zero)
        setupUI()
        apply(configuration: configuration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        clipsToBounds = true
        layer.cornerRadius = 10

        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)

        imageView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(imageView.snp.width).dividedBy(2)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
            make.top.equalTo(imageView.snp.bottom).offset(10)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.bottom.equalToSuperview().inset(10)
        }
    }

    private func apply(configuration: FeedItemCellContentConfiguration) {
        guard appliedConfiguration != configuration else { return }
        appliedConfiguration = configuration

        imageView.kf.setImage(with: configuration.imageUrl) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                imageView.snp.remakeConstraints { make in
                    make.leading.top.trailing.equalToSuperview()
                    make.height.equalTo(self.imageView.snp.width).dividedBy(2)
                }
            case .failure:
                imageView.snp.remakeConstraints { make in
                    make.leading.top.trailing.equalToSuperview()
                    make.height.equalTo(0)
                }
            }
        }
        
        titleLabel.text = configuration.title
        titleLabel.font = configuration.isSeen ? .systemFont(ofSize: 16, weight: .regular) : .systemFont(ofSize: 16, weight: .bold)

        if let attributedDescription = configuration.attributedDescription {
            descriptionLabel.attributedText = attributedDescription
        } else {
            descriptionLabel.text = configuration.description
        }

    }
}
