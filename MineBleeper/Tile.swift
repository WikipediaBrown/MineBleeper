//
//  Tile.swift
//  MineBleeper
//
//  Created by Wikipedia Brown on 11/29/19.
//  Copyright © 2019 IamGoodBad. All rights reserved.
//

import Foundation

protocol Bleepable {
    var flagged: Bool { get set }
    var isBleep: Bool { get set }
    var surroundingBleeps: Int? { get set }
}

class Tile: Bleepable {
    
    let column: Int
    let row: Int
    
    var flagged: Bool
    var isBleep: Bool
    var surroundingBleeps: Int?
    
    init(column: Int, row: Int) {
        self.column = column
        self.row = row
        
        self.flagged = false
        self.isBleep = false
    }
    
}
