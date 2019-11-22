//
//  RootLabel.swift
//  MineBleeper
//
//  Created by Wikipedia Brown on 11/8/19.
//  Copyright © 2019 IamGoodBad. All rights reserved.
//

import UIKit

class RootLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
//        alpha = 1
        adjustsFontSizeToFitWidth = true
        font = UIFont.systemFont(ofSize: 500, weight: .black)
        numberOfLines = 2
        preservesSuperviewLayoutMargins = true
        text = "Mine Bleeper"
        textColor = .white
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
