//
//  Constants.swift
//  MineBleeper
//
//  Created by Wikipedia Brown on 11/7/19.
//  Copyright © 2019 IamGoodBad. All rights reserved.
//

import UIKit

enum Constants {
    enum Integers {
        static var columns: Int {
            switch UIDevice.current.userInterfaceIdiom {
            case .pad: return 35
            case .phone: return 15
            default: return 0
            }
        }
        static var rows: Int {
            switch UIDevice.current.userInterfaceIdiom {
            case .pad: return 25
            case .phone: return 32
            default: return 0
            }
        }
    }
    enum Doubles {
        static let bleepRatio: Double = 0.99
    }
    enum Colors {
        static var successGreen: UIColor { UIColor(red: 126/255, green: 235/255, blue: 136/255, alpha: 1) }
    }
}
