//
//  Cell.swift
//  MineBleeper
//
//  Created by Wikipedia Brown on 11/7/19.
//  Copyright © 2019 IamGoodBad. All rights reserved.
//

import UIKit

class Cell: UILabel {
    
    var isBleep = false
    
    let row: Int
    let column: Int
        
    init(row: Int, column: Int) {
        self.row = row
        self.column = column
        super.init(frame: .zero)
        backgroundColor = .black
        font = UIFont(name: "KarmaticArcade", size: 8)
        isUserInteractionEnabled = true
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
        textAlignment = .center
        translatesAutoresizingMaskIntoConstraints = false
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
