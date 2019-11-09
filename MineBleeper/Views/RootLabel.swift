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
        alpha = 0
        numberOfLines = 2
        text = "Mine\nBleeper"
        font = UIFont(name: "KarmaticArcade", size: 500)
        adjustsFontSizeToFitWidth = true
        textColor = .white
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
