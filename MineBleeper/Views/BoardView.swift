//
//  BoardView.swift
//  MineBleeper
//
//  Created by Wikipedia Brown on 11/7/19.
//  Copyright © 2019 IamGoodBad. All rights reserved.
//

import UIKit

class BoardView: UIStackView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        alpha = 0
        axis = .vertical
        alignment = .fill
        distribution = .fillEqually
        contentMode = .scaleToFill
        autoresizesSubviews = true
        isUserInteractionEnabled = true
        spacing = 0
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
