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
        font = UIFont(name: "KarmaticArcade", size: UIFont.systemFontSize)
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
    
    func update(with tile: Bleepable?) {
        guard tile?.flagged == false else { text = "⚑"; return }
        guard let bleepCount = tile?.surroundingBleeps else { return }
        
        backgroundColor = .white
        
        switch bleepCount {
        case 0:
            textColor = .black
        case 1:
            textColor = .blue
        case 2:
            textColor = .green
        case 3:
            textColor = .purple
        case 4:
            textColor = .orange
        case 5:
            textColor = .magenta
        case 6:
            textColor = .brown
        case 7:
            textColor = .link
        case 8:
            textColor = .systemIndigo
        default:
            break
        }
        
        if bleepCount > 0 { text = String(describing: bleepCount) }
        else { text = nil }
    }
}
