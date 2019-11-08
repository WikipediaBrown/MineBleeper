//
//  ViewController.swift
//  MineBleeper
//
//  Created by Wikipedia Brown on 11/7/19.
//  Copyright © 2019 IamGoodBad. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
    private let bleeps = 70
    private let columns = 15
    private let navigationBar = RootBar()
    private let rows = 29
    private let stackView = BoardView()
    private var board: [[Cell]] = []
    private var statusBarShouldHide = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        statusBarShouldHide = !statusBarShouldHide
        UIView.animate(withDuration: 2) { [weak self] in
            self?.stackView.alpha = 1
            self?.setNeedsStatusBarAppearanceUpdate()
        }
        
        UIView.animate(withDuration: 3) { [weak self] in
            self?.navigationBar.alpha = 1
        }
    }
    
    override var prefersStatusBarHidden: Bool { statusBarShouldHide }
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { .slide }
    
    private func setupViews() {
        let item = UINavigationItem()
        let left = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(restart))
        let right = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(cheat))
        
        view.backgroundColor = .black
        view.addSubview(stackView)
        view.addSubview(navigationBar)
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            navigationBar.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
        ])

        item.setLeftBarButton(left, animated: true)
        item.setRightBarButton(right, animated: true)
        navigationBar.pushItem(item, animated: true)
        board = setupGame(rows: rows, columns: columns)
        setupBleeps(numberOfBleeps: bleeps)
    }
    
    @objc
    func restart() {}
    
    @objc
    func cheat() {}
    
    func loseGame() {
        let alert = UIAlertController(title: "Bleep Thiiiiis...", message: "You've Lost... you shouldn't do that my dudes...", preferredStyle: .alert)
        let again = UIAlertAction(title: "Try Again Loser", style: .destructive, handler: reset)
        alert.addAction(again)
        present(alert, animated: true, completion: nil)
    }
    
    private func reset(action: UIAlertAction) {
        stackView.subviews.forEach { $0.removeFromSuperview() }
        board = setupGame(rows: rows, columns: columns)
        setupBleeps(numberOfBleeps: bleeps)
    }
    
    private func setupGame(rows: Int, columns: Int) -> [[Cell]] {
        var board = [[Cell]]()
        for row in 0..<rows {
            var thisRow = [Cell]()
            let rowView = UIStackView()
            rowView.axis = .horizontal
            rowView.distribution = .fillEqually
            for column in 0..<columns {
                let cell = getCell(row: row, column: column)
                thisRow.append(cell)
                rowView.addArrangedSubview(cell)
            }
            board.append(thisRow)
            stackView.addArrangedSubview(rowView)
        }
        return board
    }
    
    private func setupBleeps(numberOfBleeps: Int) {
        let totalCells = rows * columns
        var set = Set<Int>()
        while set.count < numberOfBleeps {
            set.insert(Int.random(in: 0..<totalCells))
        }
        for index in set {
            let row: Int = Int(floor(Float(index / columns)))
            let column: Int = index % columns
            
            board[row][column].backgroundColor = .red
            board[row][column].isBleep = true
        }
    }
    
    
    @objc
    private func check(sender: UITapGestureRecognizer) {
        guard let cell = sender.view as? Cell, cell.text == nil else { return }
        if cell.isBleep {
            cell.backgroundColor = .red
            loseGame()
        } else {
            test(cell: cell)
        }
    }
        
    private func test(cell: Cell) {
        let row = cell.row
        let column = cell.column
        
        
        let bleepCount = checkIndex(row: cell.row, column: cell.column, in: board)
        cell.text = String(bleepCount)
        cell.backgroundColor = .white
        
        if bleepCount == 0 {
            for x in -1...1 {
                guard row + x < board.count, row + x >= 0 else { continue }
                for y in -1...1 {
                    guard column + y < board[row + x].count, column + y >= 0 else { continue }
                    guard (row + x, column + y) != (row, column) else { continue }
                    guard board[row + x][column + y].text == nil else { continue }
                    let cell = board[row + x][column + y]
                    test(cell: cell)
                }
            }
        }
        
        
    }
    
    @objc
    private func flag(sender: UITapGestureRecognizer) {
        guard let cell = sender.view as? Cell else { return }
        switch sender.state {
        case .began:
            if cell.text == "F" {
                cell.text = nil
            } else {
                cell.text = "F"
            }
        default:
            break
        }
    }
    
    private func checkIndex(row: Int, column: Int, in board: [[UIView]]) -> Int {
        var bleepCount = 0
        for x in -1...1 {
            guard row + x < board.count, row + x >= 0 else { continue }
            for y in -1...1 {
                guard column + y < board[row + x].count, column + y >= 0 else { continue }
                guard (row + x, column + y) != (row, column) else { continue }
                guard let cell = board[row + x][column + y] as? Cell else { continue }
                if cell.isBleep { bleepCount += 1}
            }
        }
        return bleepCount
    }
    
    private func getCell(row: Int, column: Int) -> Cell {
        let cell = Cell(row: row, column: column)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(check))
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(flag))
        
        cell.addGestureRecognizer(tap)
        cell.addGestureRecognizer(longPress)
        
        return cell
    }

}

