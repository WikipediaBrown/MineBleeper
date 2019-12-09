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
        tintColor = .white
        barStyle = .black
        barTintColor = .black
        isTranslucent = false
        titleTextAttributes = [.foregroundColor: UIColor.red,
                               .font: UIFont.systemFont(ofSize: UIFont.buttonFontSize, weight: .black)]
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
