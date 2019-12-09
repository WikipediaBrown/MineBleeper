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
        guard tile?.flagged == false else {textColor = .red; text = "⚑"; return }

        backgroundColor = tile?.surroundingBleeps == nil ? .black : .white
        font = UIFont(name: "KarmaticArcade", size: UIFont.systemFontSize)
        text = tile?.surroundingBleeps?.description
        
        switch tile?.surroundingBleeps {
        case 0:
            text = nil; return 
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
    }
}
