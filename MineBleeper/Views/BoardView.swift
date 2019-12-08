//
//  BoardView.swift
//  MineBleeper
//
//  Created by Wikipedia Brown on 11/7/19.
//  Copyright © 2019 IamGoodBad. All rights reserved.
//

import UIKit

protocol BoardViewListening: class {
    func numberOfColumns() -> Int
    func numberOfRows() -> Int
    func viewTapped(at column: Int, and row: Int)
    func viewLongPressed(at column: Int, and row: Int)
}

class BoardView: UIStackView {
    
    var listener: BoardViewListening?
    var board: [[Cell]]

    override init(frame: CGRect) {
        self.board = []
        super.init(frame: frame)
        alpha = 1
        axis = .horizontal
        alignment = .fill
        distribution = .fillEqually
        contentMode = .scaleToFill
        autoresizesSubviews = true
        isUserInteractionEnabled = true
        spacing = 0
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateIndex(with indexPath: IndexPath, with tile: Bleepable?) {
        board[indexPath.section][indexPath.row].update(with: tile)
    }
    
    @objc func open(sender: Cell) { listener?.viewTapped(at: sender.column, and: sender.row) }
    @objc func flag(sender: Cell) { listener?.viewLongPressed(at: sender.column, and: sender.row) }
    
    private func getCell(row: Int, column: Int) -> Cell {
        let cell = Cell(row: row, column: column)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(open))
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(flag))
        
        cell.addGestureRecognizer(tap)
        cell.addGestureRecognizer(longPress)
        
        return cell
    }
    
    func setupGame(rows: Int?, columns: Int?) {
        guard let rows = rows, let columns = columns else { return }
        
        board = [[Cell]]()
        arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for column in 0..<columns {
            var thisColumn = [Cell]()
            let columnView = UIStackView()
            columnView.axis = .vertical
            columnView.distribution = .fillEqually
            for row in 0..<rows {
                let cell = getCell(row: row, column: column)
                thisColumn.append(cell)
                columnView.addArrangedSubview(cell)
            }
            board.append(thisColumn)
            addArrangedSubview(columnView)
        }
    }
    
}
