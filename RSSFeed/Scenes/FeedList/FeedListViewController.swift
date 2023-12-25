//
//  FeedListViewController.swift
//  RSSFeed
//
//  Created by Mirko Braic on 25.12.2023..
//

import UIKit
import SnapKit
import Then

class FeedListViewController: UIViewController {
    private let helloLabel = UILabel().then {
        $0.textColor = .red
        $0.text = "Hello"
    }

    private let viewModel: FeedListViewModel

    init(viewModel: FeedListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        view.addSubview(helloLabel)
        helloLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

