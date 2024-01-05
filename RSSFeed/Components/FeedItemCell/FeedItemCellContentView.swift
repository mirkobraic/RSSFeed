//
//  FeedItemCellContentView.swift
//  RSSFeed
//
//  Created by Mirko Braic on 02.01.2024..
//

import UIKit
import Then
import Kingfisher

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
        $0.backgroundColor = .lightGray.withAlphaComponent(0.1)
    }
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .bold)
        $0.numberOfLines = 0
    }
    private let dateLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = .secondaryLabel
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
        addSubview(dateLabel)
        addSubview(descriptionLabel)

        imageView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(imageView.snp.width).multipliedBy(0.5)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
            make.top.equalTo(imageView.snp.bottom).offset(10)
        }

        dateLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(titleLabel)
            make.top.equalTo(dateLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview().inset(10).priority(.high)
        }
    }
    
    private func apply(configuration: FeedItemCellContentConfiguration) {
        guard appliedConfiguration != configuration else { return }
        appliedConfiguration = configuration

        titleLabel.text = configuration.title
        titleLabel.font = configuration.isSeen ? .systemFont(ofSize: 16, weight: .regular) : .systemFont(ofSize: 16, weight: .bold)
        dateLabel.text = configuration.date
        if let attributedDescription = configuration.attributedDescription {
            descriptionLabel.attributedText = attributedDescription
        } else {
            descriptionLabel.text = configuration.description
        }
        setImage(from: configuration.imageUrl)
    }

    private func setImage(from url: URL?) {
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: url) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
                var ratio: CGFloat = 0
                if response.image.size.width > 50 {
                    ratio = response.image.size.height / response.image.size.width
                }
                imageView.snp.remakeConstraints { make in
                    make.leading.top.trailing.equalToSuperview()
                    make.height.equalTo(self.imageView.snp.width).multipliedBy(ratio)
                }
                invalidateIntrinsicContentSize()
            case .failure:
                imageView.snp.remakeConstraints { make in
                    make.leading.top.trailing.equalToSuperview()
                    make.height.equalTo(0)
                }
                invalidateIntrinsicContentSize()
            }
        }
    }
}
