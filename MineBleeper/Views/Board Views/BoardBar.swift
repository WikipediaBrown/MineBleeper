//
//  RootBar.swift
//  MineBleeper
//
//  Created by Wikipedia Brown on 11/7/19.
//  Copyright © 2019 IamGoodBad. All rights reserved.
//

import UIKit

class BoardBar: UINavigationBar {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        alpha = 0
        tintColor = .white
        barTintColor = .black
        isTranslucent = false
        titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.red]
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
