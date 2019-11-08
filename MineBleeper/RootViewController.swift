//
//  ViewController.swift
//  MineBleeper
//
//  Created by Wikipedia Brown on 11/7/19.
//  Copyright © 2019 IamGoodBad. All rights reserved.
//

import UIKit

/// The root view controller for MineBleeper. It has basic funtionality for administering a MineBleeper game.
class RootViewController: UIViewController {
    
    // MARK: - Open Properties
    
    var bleeps = Set<Int>()
    
    // MARK: - Private Properties

    private let bleepCount = 45
    private let columns = 12
    private let navigationBar = RootBar()
    private let rows = 24
    private let stackView = BoardView()
    
    private var board: [[Cell]] = []
    private var cellCount: Int {rows * columns}
    private var cellsChecked = 0
    private var openableCells: Int {cellCount - bleepCount}
    private var statusBarShouldHide = true
    private var winConditionMet: Bool { cellsChecked == openableCells }
    
    
    // MARK: - Overriden Properties

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { .slide }
    override var prefersStatusBarHidden: Bool { statusBarShouldHide }

    // MARK: - Overriden Methods

    override func viewDidLoad() { super.viewDidLoad(); setupViews() }

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
    
    // MARK: - User Interaction Methods
    
    @objc
    func restart(action: UIAlertAction) {
        cellsChecked = 0
        stackView.subviews.forEach { $0.removeFromSuperview() }
        board = setupGame(rows: rows, columns: columns)
        bleeps.removeAll()
        setupBleeps(numberOfBleeps: bleepCount)
    }
    
    private func reset(action: UIAlertAction) {
        cellsChecked = 0
        stackView.subviews.forEach { $0.removeFromSuperview() }
        board = setupGame(rows: rows, columns: columns)
        setupBleeps(numberOfBleeps: bleepCount)
    }

    @objc
    func cheat() {
        toggleBleeps()
    }
    
    @objc
    func check(sender: UITapGestureRecognizer) {
        guard let cell = sender.view as? Cell, cell.text == nil else { return }
        if cell.isBleep {
            cell.backgroundColor = .red
            lose()
        } else {
            test(cell: cell)
        }
    }
    
    @objc
    func flag(sender: UITapGestureRecognizer) {
        guard let cell = sender.view as? Cell else { return }
        switch sender.state {
        case .began:
            if cell.text == "⚑" {
                cell.text = nil
            } else {
                cell.text = "⚑"
            }
        default:
            break
        }
    }
    
    func lose() {
        present(getAlert(type: .lost), animated: true, completion: nil)
    }
    
    func win() {
        present(getAlert(type: .won), animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    
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
    
    private func getAlert(type: Constants.AlertType) -> UIAlertController {
        let title: String
        let message: String
        let action: UIAlertAction
        
        switch type {
        case .lost:
            title = "Bleep Thiiiiis..."
            message = "You've Lost... you shouldn't do that my dudes..."
            action = UIAlertAction(title: "Try Again Loser", style: .destructive, handler: reset)
        case .won:
            title = "You did iiiiit..."
            message = "yaaaay..."
            action = UIAlertAction(title: "DO IT AGAIN", style: .destructive, handler: reset)
        }
         
        let alert =  UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(action)
        
        return alert
    }
    
    private func getCell(row: Int, column: Int) -> Cell {
        let cell = Cell(row: row, column: column)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(check))
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(flag))
        
        cell.addGestureRecognizer(tap)
        cell.addGestureRecognizer(longPress)
        
        return cell
    }
    
    private func setupBleeps(numberOfBleeps: Int) {
        while bleeps.count < numberOfBleeps {
            bleeps.insert(Int.random(in: 0..<rows * columns))
        }
        for index in bleeps {
            let row: Int = Int(floor(Float(index / columns)))
            let column: Int = index % columns
            board[row][column].isBleep = true
        }
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
    
    private func setupViews() {
        let item = UINavigationItem()
           
        let left = UIButton(type: .custom)
        left.titleLabel?.numberOfLines = 2
        left.setTitle("TRY\nAGAIN", for: .normal)
        left.sizeToFit()
        left.addTarget(self, action: #selector(restart), for: .touchUpInside)
        left.titleLabel?.font = UIFont(name: "KarmaticArcade", size: 12)
        let tryAgain = UIBarButtonItem(customView: left)
        
        let right = UIButton(type: .custom)
        right.titleLabel?.numberOfLines = 2
        right.titleLabel?.textAlignment = .right
        right.setTitle("TRY\nCHEATING", for: .normal)
        right.sizeToFit()
        right.addTarget(self, action: #selector(cheat), for: .touchUpInside)
        right.titleLabel?.font = UIFont(name: "KarmaticArcade", size: 12)
        let cheat = UIBarButtonItem(customView: right)
                
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

        item.setLeftBarButton(tryAgain, animated: true)
        item.setRightBarButton(cheat, animated: true)
        navigationBar.pushItem(item, animated: true)
        board = setupGame(rows: rows, columns: columns)
        setupBleeps(numberOfBleeps: bleepCount)
    }
        
    private func test(cell: Cell) {
        let row = cell.row
        let column = cell.column
        
        
        let bleepCount = checkIndex(row: cell.row, column: cell.column, in: board)
        cell.text = String(bleepCount)
        cell.backgroundColor = .white
        cellsChecked += 1
        
        if winConditionMet { win(); return }
        
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
    
    private func toggleBleeps() {
        for index in bleeps {
            let row: Int = Int(floor(Float(index / columns)))
            let column: Int = index % columns
            board[row][column].backgroundColor =  board[row][column].backgroundColor == .red ? .black : .red
            board[row][column].textColor = .black
            board[row][column].text = board[row][column].text == nil ? "☠︎" : nil
        }
    }

}

