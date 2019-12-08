//
//  BoardCollectionView.swift
//  MineBleeper
//
//  Created by Wikipedia Brown on 12/7/19.
//  Copyright © 2019 IamGoodBad. All rights reserved.
//

import UIKit

class BoardCollectionView: UICollectionView {
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal

        super.init(frame: .zero, collectionViewLayout: layout)
        backgroundColor = .red
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
        register(TileCell.self, forCellWithReuseIdentifier: TileCell.description())
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
