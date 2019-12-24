//
//  MineBleeper.swift
//  MineBleeper
//
//  Created by Wikipedia Brown on 12/24/19.
//  Copyright © 2019 IamGoodBad. All rights reserved.
//

import Foundation

class MineBleeper {
    
    struct Index {
        let column: Int
        let row: Int
        
        var adjacentBleeps: Int?
        var isBleep: Bool = false
    }
    
    enum State {
        case notStarted
        case inProgress
        case won
        case lost
    }
    
    var state: State = .notStarted
    
    var rows: Int = 0
    var columns: Int = 0
    
    var board: [[Index]] = []
    var bleepIndicies: [(column: Int, row: Int)] = []
    
    
//    var numberOfTaps: Int = 0
    var numberOfBleeps: Int = 0
    
    var openedCount: Int = 0
        
    func setupGame(columns: Int, rows: Int, bleepRatio: Double?) {
        board.removeAll()
        for column in 0..<columns {
            var thisColumn = [Index]()
            for row in 0..<rows {
                thisColumn.append(Index(column: column, row: row))
            }
            board.append(thisColumn)
        }
    }
    
    private func setupBleeps(numberOfBleeps bleeps: Int, excluding excluded: (column: Int, row: Int)) {
        guard numberOfBleeps <= board.count * board[0].count else { return }
        let indexCount = board.count * board[0].count
        var bleeps = Set<Int>()
        
        while bleeps.count < numberOfBleeps {
            bleeps.insert(Int.random(in: 0..<indexCount))
        }
        
        for number in bleeps {
            let column = number % columns
            let row = Int(floor(Float(number / columns)))
            if column == excluded.column && row == excluded.row { continue }
            
            board[column][row].isBleep = true
            bleepIndicies.append((column: column, row: row))
        }
    }
    
    private func open(column: Int, row: Int) {
        guard board.count > column, board[column].count > row else { return }

        openedCount += 1
//        board[column][row].surroundingBleeps = checkSurrounding(row: row, column: column)
//
//        if winConditionMet { win(); return }
//        if let count = board[column][row].surroundingBleeps, count > 0 { return }
//
//        for x in -1...1 {
//            guard column + x < board.count, column + x >= 0 else { continue }
//            for y in -1...1 {
//                guard row + y < board[column + x].count, row + y >= 0 else { continue }
//                guard (column + x, row + y) != (column, row) else { continue }
//                guard board[column + x][row + y].surroundingBleeps == nil else { continue }
//                open(column: column + x, row: row + y)
//            }
//        }
    }
    
    private func checkSurrounding(row: Int, column: Int) -> Int {
        // Start counting
        var count = 0
        
        for x in -1...1 {
            // Skip columns coordinates outside of board space
            guard column + x < board.count, column + x >= 0 else { continue }
            for y in -1...1 {
                // Skip rows coordinates outside of board space
                guard row + y < board[column + x].count, row + y >= 0 else { continue }
                // Skip the index being checked
                guard (column + x, row + y) != (column, row) else { continue }
                // If index is a Bleep, increment count
                if board[column + x][row + y].isBleep { count += 1}
            }
        }
        // return count
        return count
    }
    
    func reset() {
        openedCount = 0
    }
    
    func checkIndex() {}
    func showBoard() {}
    
    func win() {}
    func lose() {}
    
}


