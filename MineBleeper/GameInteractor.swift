//
//  GameInteractor.swift
//  MineBleeper
//
//  Created by Wikipedia Brown on 11/29/19.
//  Copyright © 2019 IamGoodBad. All rights reserved.
//

import UIKit

protocol GamePresentable {
    func presentError()
    func presentLogin()
    func presentGame()
    func presentResult(with  bleeps: [IndexPath], and gameState: GameState)
    func presentScore(score: Int)
    func toggleBleeps(at indexPaths: [IndexPath])
    func update(indexPaths: [IndexPath], with feedback: GameFeedback)
}

class GameInteractor: GameInteractable {
    
    private var columns: Int = Constants.Integers.columns
    private var rows: Int = Constants.Integers.rows
    private let bleepRatio: Double = Constants.Doubles.bleepRatio
    private var numberOfBleeps: Int = Int(floor(Double(Constants.Integers.columns * Constants.Integers.rows) * Constants.Doubles.bleepRatio))

    private let movement: Movement
    
    private var gameState: GameState
    private var presenter: GamePresentable
    private var board: [[Bleepable]]
    private var bleepIndexPaths: [IndexPath]
    private var indicesToUpdate: [IndexPath]
    private var score: Int
    private var selections: Int
    private var openedCount: Int
    private var isCheating: Bool = false
    private var cellCount: Int { board.count * board[0].count }
    private var openableCells: Int { cellCount - numberOfBleeps }
    private var winConditionMet: Bool { openedCount == openableCells }
    private var percentComplete: Int { openedCount / openableCells }
    
    init(movement: Movement, presenter: GamePresentable) {
        self.gameState = .notStarted
        self.bleepIndexPaths = []
        self.indicesToUpdate = []
        self.board = []
        self.movement = movement
        self.presenter = presenter
        self.openedCount = 0
        self.score = 0
        self.selections = 0
    }
    
    func onColumnCount() -> Int { board.count }
    func onRowCount() -> Int { board.first?.count ?? 0 }
    func onTileRequest(at indexPath: IndexPath) -> Bleepable { board[indexPath.section][indexPath.row] }
    func onDidAppear() { presenter.presentLogin() }
    func onAppleLogin() {}
    
    func onGuestLogin() {
        _ = movement.add { [weak self] in self?.onTic() }
        presenter.presentGame()
    }
    
    func onSelectIndex(at indexPath: IndexPath) {
        guard gameState == .inProgress || gameState == .notStarted else { return }
        let row = indexPath.row
        let column = indexPath.section
        let cell = board[column][row]
        
        if winConditionMet { return }
        
        if cell.flagged { return }
        
        if cell.surroundingBleeps != nil { return }
        
        if isCheating && cell.isBleep { return }

        if selections == 0 { firstSelection(at: indexPath) }
                        
        if cell.isBleep { lose(); return }
        else { open(column: column, row: row) }
        
        selections += 1
        update(feedback: .open)
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
    }
    
    func onToggleFlag(at indexPath: IndexPath) {
        guard gameState == .inProgress else { return }
        let row = indexPath.row
        let column = indexPath.section
        guard board[column][row].surroundingBleeps == nil else { return }
        
        board[column][row].flagged = !board[column][row].flagged
        let feedback: GameFeedback = board[column][row].flagged ? .flag : .unflag
        indicesToUpdate.append(indexPath)
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
        update(feedback: feedback)
    }
    
    
    func toggleTryCheating() {
        guard gameState == .inProgress else { return }
        isCheating = !isCheating
        presenter.toggleBleeps(at: bleepIndexPaths)
    }
    
    func onTryAgain() {
        score = 0
        openedCount = 0
        selections = 0
        isCheating = false
        movement.reset()
        setupBoard()
        update(feedback: .tryAgain)
        presenter.presentScore(score: score)
        gameState = .notStarted
    }
    
    private func checkSurrounding(row: Int, column: Int) -> Int {
        var count = 0
        
        for x in -1...1 {
            guard column + x < board.count, column + x >= 0 else { continue }
            for y in -1...1 {
                guard row + y < board[column + x].count, row + y >= 0 else { continue }
                guard (column + x, row + y) != (column, row) else { continue }
                if board[column + x][row + y].isBleep { count += 1}
            }
        }
        
        return count
    }
    
    private func firstSelection(at indexPath: IndexPath) {
        gameState = .inProgress
        movement.start()
        setupBleeps(numberOfBleeps: numberOfBleeps, excluding: indexPath)
    }
    
    private func lose() {
        gameState = .lost
        presenter.presentResult(with: bleepIndexPaths, and: .lost)
        movement.reset()
    }
    
    private func win() {
        gameState = .won
        presenter.presentResult(with: bleepIndexPaths, and: .won)
        movement.reset()
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
                open(column: column + x, row: row + y)
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
    
    private func onTic() {
        score += selections;
        print(score)
        presenter.presentScore(score: score)
    }
    
    private func error() { presenter.presentError() }
    private func update(feedback: GameFeedback) {
        presenter.update(indexPaths: indicesToUpdate, with: feedback)
        indicesToUpdate.removeAll()
    }

}
