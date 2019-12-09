//
//  GuestButton.swift
//  MineBleeper
//
//  Created by Wikipedia Brown on 11/11/19.
//  Copyright © 2019 IamGoodBad. All rights reserved.
//

import UIKit

class GuestButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
        setTitleColor(.white, for: .normal)
        setTitle("Play as 'Guest'", for: .normal)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
