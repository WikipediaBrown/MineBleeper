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
    func presentLoss(with bleeps: [IndexPath])
    func presentWin(with bleeps: [IndexPath])
    func presentScore(score: Int)
    func toggleBleeps(at indexPaths: [IndexPath])
    func update(indexPaths: [IndexPath])
}

class GameInteractor: GameInteractable {
    
    // temporary values
    private var columns: Int
    private var rows: Int
    private var numberOfBleeps: Int
    private let bleepRatio: Double = 0.2
    //
    
    private let movement: Movement
    
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
        switch UIDevice.current.userInterfaceIdiom {
//        case .carPlay:
//            print(UIDevice.current.userInterfaceIdiom)
        case .pad:
            print(UIDevice.current.userInterfaceIdiom.rawValue)
            columns = 35
            rows = 25
            numberOfBleeps = Int(floor(Double(columns * rows) * bleepRatio))
        case .phone:
            columns = 15
            rows = 32
            numberOfBleeps = Int(floor(Double(columns * rows) * bleepRatio))
            print(UIDevice.current.userInterfaceIdiom.rawValue)
//        case .tv:
//            print(UIDevice.current.userInterfaceIdiom)
//        case .unspecified:
//            print(UIDevice.current.userInterfaceIdiom)
        default:
            columns = 0
            rows = 0
            numberOfBleeps = 0
            break
        }
        
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
    
    
    func onDidAppear() {
        presenter.presentLogin()
    }
    
    func onAppleLogin() {
        
    }
    
    func onGuestLogin() {
        _ = movement.add { [weak self] in self?.onTic() }
        presenter.presentGame()
    }

    func onSelectIndex(at indexPath: IndexPath) {
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
    }
    
    func onToggleFlag(at indexPath: IndexPath) {
        let row = indexPath.row
        let column = indexPath.section
        guard board[column][row].surroundingBleeps == nil else { return }
        
        board[column][row].flagged = !board[column][row].flagged
        indicesToUpdate.append(indexPath)
        update()
    }
    
    
    func toggleTryCheating() {
        isCheating = !isCheating
        presenter.toggleBleeps(at: bleepIndexPaths)
    }
    
    func onTryAgain() {
        score = 0
        openedCount = 0
        selections = 0
        movement.reset()
        setupBoard()
        update()
        presenter.presentScore(score: score)
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
        movement.start()
        setupBleeps(numberOfBleeps: numberOfBleeps, excluding: indexPath)
    }
    
    private func lose() {
        presenter.presentLoss(with: bleepIndexPaths)
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
    private func win() { presenter.presentWin(with: bleepIndexPaths) }
    private func update() { presenter.update(indexPaths: indicesToUpdate); indicesToUpdate.removeAll() }

}
