//
//  CategoryHeader.swift
//  RSSFeed
//
//  Created by Mirko Braic on 05.01.2024..
//

import UIKit
import SnapKit
import Then

class CategoryHeader: UICollectionReusableView {
    let label = UILabel().then {
        $0.textColor = .secondaryLabel
        $0.font = .systemFont(ofSize: 12)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}
