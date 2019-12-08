//
//  GameInteractor.swift
//  MineBleeper
//
//  Created by Wikipedia Brown on 11/29/19.
//  Copyright © 2019 IamGoodBad. All rights reserved.
//

import UIKit

protocol GameInteractable {
    func onColumnCount() -> Int
    func onRowCount() -> Int
    func onSelectIndex(at indexPath: IndexPath)
    func onToggleFlag(at indexPath: IndexPath)
    func onTryAgain()
    func toggleTryCheating()
}

protocol GamePresentable {
    func presentError()
    func presentLoss()
    func presentWin()
    func presentScore(score: Int)
    func update(indexPaths: [IndexPath])
}

class GameInteractor: GameInteractable {
    
    
    
    func onTryAgain() {
        setupBoard()
    }
    
    func toggleTryCheating() {
        
    }
    
    // temporary values
    private let columns = 15
    private let rows = 30
    //
    
    private let movement: Movement
    
    private var presenter: GamePresentable

    private var board: [[Bleepable]]
    private var bleepIndexPaths: [IndexPath]
    private var indicesToUpdate: [IndexPath]
    private var numberOfBleeps: Int
    private var score: Int
    private var selections: Int
    private var openedCount: Int
    private var cellCount: Int { board.count * board[0].count }
    private var openableCells: Int { cellCount - numberOfBleeps }
    private var winConditionMet: Bool { openedCount == openableCells }
    
    init(movement: Movement, presenter: GamePresentable) {
        self.board = []
        self.bleepIndexPaths = []
        self.indicesToUpdate = []
        self.movement = movement
        self.numberOfBleeps = 10
        self.openedCount = 0
        self.presenter = presenter
        self.score = 0
        self.selections = 0
    }
    
    func onColumnCount() -> Int { board.count }
    func onRowCount() -> Int { board.first?.count ?? 0 }
    func onTileRequest(at indexPath: IndexPath) -> Bleepable { board[indexPath.section][indexPath.row] }

    func onSelectIndex(at indexPath: IndexPath) {
        let row = indexPath.row
        let column = indexPath.section
        let cell = board[column][row]
        
        if cell.flagged { return }
        
        if selections == 0 { firstSelection(at: indexPath) }
                
        if cell.isBleep { lose(); return }
        else { open(column: column, row: row) }
        
        selections += 1
        update()
    }
    
    func setupBoard() {
        board.removeAll()
        indicesToUpdate.removeAll()
        
        for column in 0..<columns {
            var thisColumn = [Bleepable]()
            for row in 0..<rows {
                indicesToUpdate.append(IndexPath(row: row, section: column))
                thisColumn.append(Tile(column: column, row: row))
            }
            board.append(thisColumn)
        }
        
//        update()
    }
    
    func onToggleFlag(at indexPath: IndexPath) {
        let row = indexPath.row
        let column = indexPath.section
        
        board[column][row].flagged = !board[column][row].flagged
        indicesToUpdate.append(indexPath)
        update()
    }
    
    private func checkSurrounding(row: Int, column: Int) -> Int {
        var count = 0
        
        for x in -1...1 {
            guard row + x < board.count, row + x >= 0 else { continue }
            for y in -1...1 {
                guard column + y < board[row + x].count, column + y >= 0 else { continue }
                guard (row + x, column + y) != (row, column) else { continue }
                if board[row + x][column + y].isBleep { count += 1}
            }
        }
        
        return count
    }
    
    private func firstSelection(at indexPath: IndexPath) {
        _ = movement.add { [weak self] in self?.onTic() }
        movement.start()
        setupBleeps(numberOfBleeps: numberOfBleeps, excluding: indexPath)
    }
    
    private func open(column: Int, row: Int) {
        guard board.count > column, board[column].count > row else { return }

        openedCount += 1
        board[column][row].surroundingBleeps = checkSurrounding(row: row, column: column)
        indicesToUpdate.append(IndexPath(row: row, section: column))
        
        if winConditionMet { win(); return }
        if let count = board[column][row].surroundingBleeps, count > 0 { return }
        
        for x in -1...1 {
            guard column + x < board.count, column + x >= 0 else { continue }
            for y in -1...1 {
                guard row + y < board[column + x].count, row + y >= 0 else { continue }
                guard (column + x, row + y) != (column, row) else { continue }
                guard board[column + x][row + y].surroundingBleeps == nil else { continue }
                open(column: column + y, row: row + x)
            }
        }
    }
    
    private func setupBleeps(numberOfBleeps bleeps: Int, excluding excluded: IndexPath) {
        guard numberOfBleeps <= board.count * board[0].count else { return }
        
        self.numberOfBleeps = bleeps
        var bleeps = Set<IndexPath>()
        
        while bleeps.count < numberOfBleeps {
            let column = Int.random(in: 0..<board.count)
            let row = Int.random(in: 0..<board[0].count)
            let indexPath = IndexPath(row: row, section: column)
            if indexPath != excluded { bleeps.insert(indexPath) }
        }
        
        for indexPath in bleeps {
            board[indexPath.section][indexPath.row].isBleep = true
        }
        
        bleepIndexPaths = Array(bleeps)
    }

    private func error() { presenter.presentError() }
    private func lose() { presenter.presentLoss() }
    private func onTic() { score += 1; presenter.presentScore(score: score) }
    private func win() { presenter.presentWin() }
    private func update() { presenter.update(indexPaths: indicesToUpdate); indicesToUpdate.removeAll() }

}
