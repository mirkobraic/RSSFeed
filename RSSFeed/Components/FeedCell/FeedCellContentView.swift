//
//  FeedCellContentView.swift
//  RSSFeed
//
//  Created by Mirko Braic on 31.12.2023..
//

import UIKit
import SnapKit
import Then
import Kingfisher

class FeedCellContentView: UIView, UIContentView {
    private var appliedConfiguration: FeedCellContentConfiguration!
    var configuration: UIContentConfiguration {
        get { appliedConfiguration }
        set {
            guard let newConfig = newValue as? FeedCellContentConfiguration else { return }
            apply(configuration: newConfig)
        }
    }

    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
    }
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.numberOfLines = 0
    }
    private let descriptionLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12)
        $0.numberOfLines = 0
    }
    private let favoriteButton = UIButton().then {
        $0.tintColor = .rsTint
    }

    init(configuration: FeedCellContentConfiguration) {
        super.init(frame: .zero)
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        setupUI()
        apply(configuration: configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func favoriteButtonTapped() {
        appliedConfiguration.favoriteTapCallback?()
    }

    private func setupUI() {
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(favoriteButton)

        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalTo(titleLabel)
            make.width.height.equalTo(15)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalTo(imageView.snp.trailing).offset(10)
            make.trailing.equalTo(favoriteButton.snp.leading).offset(-10)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.bottom.equalToSuperview().inset(10)
        }

        favoriteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
    }

    private func apply(configuration: FeedCellContentConfiguration) {
        guard appliedConfiguration != configuration else { return }
        appliedConfiguration = configuration

        imageView.kf.setImage(with: configuration.imageUrl) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                titleLabel.snp.updateConstraints { make in
                    make.leading.equalTo(self.imageView.snp.trailing).offset(10)
                }
            case .failure:
                titleLabel.snp.updateConstraints { make in
                    make.leading.equalTo(self.imageView.snp.trailing).offset(-15)
                }
            }
        }
        titleLabel.text = configuration.title
        descriptionLabel.text = configuration.description
        let image = configuration.isFavorite ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        favoriteButton.setImage(image, for: .normal)
    }
}
