//
//  TileCell.swift
//  MineBleeper
//
//  Created by Wikipedia Brown on 12/7/19.
//  Copyright © 2019 IamGoodBad. All rights reserved.
//

import UIKit

class TileCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with tile: Bleepable?) {
        
    }
}
