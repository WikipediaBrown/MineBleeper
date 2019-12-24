//
//  Enumerations.swift
//  MineBleeper
//
//  Created by Wikipedia Brown on 12/9/19.
//  Copyright © 2019 IamGoodBad. All rights reserved.
//

import Foundation

enum GameState {
    case notStarted
    case inProgress
    case won
    case lost
}


enum GameFeedback {
    case tryAgain
    case cheat
    case open
    case flag
    case unflag
    case lose
    case win
}
