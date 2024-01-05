//
//  CategoryCell.swift
//  RSSFeed
//
//  Created by Mirko Braic on 05.01.2024..
//

import UIKit
import SnapKit
import Then

class CategoryCell: UICollectionViewCell {
    let label = UILabel().then {
        $0.textAlignment = .center
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }

    override var isSelected: Bool {
        didSet {
            contentView.layer.borderColor = isSelected ? UIColor.rsTint.cgColor : UIColor.clear.cgColor
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 10
        contentView.backgroundColor = .rsSecondaryBackground
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.clear.cgColor

        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
