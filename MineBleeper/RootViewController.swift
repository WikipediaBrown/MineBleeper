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
    private let guestbutton = GuestButton()
    private let movement = Movement()
    private let navigationBar = BoardBar()
    private let rootLabel = RootLabel()
    private let rows = 24
    private let stackView = BoardView()
    
    private var board: [[Cell]] = []
    private var cellCount: Int { rows * columns }
    private var cellsChecked = 0
    private var onTicUUID: UUID?
    private var openableCells: Int { cellCount - bleepCount }
    private var statusBarShouldHide = true
    private var winConditionMet: Bool { cellsChecked == openableCells }
    
    
    // MARK: - Overriden Properties

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { .slide }
    override var prefersStatusBarHidden: Bool { statusBarShouldHide }

    // MARK: - Overriden Methods

//    override func viewDidLoad() { super.viewDidLoad(); setupViews() }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addLogin() 
    }
    
    // MARK: - User Interaction Methods
    
    @objc
    func guestButtonTapped() {
        removeLogin { [weak self] in
            self?.setupViews()
            UIView.animate(withDuration: 2) { [weak self] in
                self?.stackView.alpha = 1
            }
            UIView.animate(withDuration: 3) { [weak self] in
                self?.navigationBar.alpha = 1
            }
        }
    }
    
    @objc
    func restart(action: UIAlertAction) {
        UISelectionFeedbackGenerator().selectionChanged()
        cellsChecked = 0
        stackView.subviews.forEach { $0.removeFromSuperview() }
        board = setupGame(rows: rows, columns: columns)
        bleeps.removeAll()
        setupBleeps(numberOfBleeps: bleepCount)
    }

    @objc
    func cheat() {
        UISelectionFeedbackGenerator().selectionChanged()
        toggleBleeps()
    }
    
    var first = true
    var taps = 0
    
    func getScore() -> Int {
        let score = Double(taps) * (movement.totalTime + 1)
        return Int(score)
    }
    
    func onTic() {
        DispatchQueue.main.async { [weak self] in
            guard let score = self?.getScore() else { return }
            self?.navigationBar.topItem?.title = "\(score)"
        }
    }
    
    @objc
    func check(sender: UITapGestureRecognizer) {
        taps += 1

        if first {
            first = false
            onTicUUID = movement.add { [weak self] in self?.onTic() }
            movement.start()
        }

        guard let cell = sender.view as? Cell, cell.text == nil else { return }
        if cell.isBleep {
            cell.backgroundColor = .red
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            lose()
        } else {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            test(cell: cell)
        }
    }
    
    @objc
    func flag(sender: UITapGestureRecognizer) {
        guard let cell = sender.view as? Cell else { return }
        switch sender.state {
        case .began:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            cell.font = UIFont.boldSystemFont(ofSize: 30)
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
            action = UIAlertAction(title: "Try Again Loser", style: .destructive, handler: restart)
        case .won:
            title = "You did iiiiit..."
            message = "yaaaay..."
            action = UIAlertAction(title: "DO IT AGAIN", style: .destructive, handler: restart)
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
    
    private func addLogin() {
        statusBarShouldHide = !statusBarShouldHide
        guestbutton.addTarget(self, action: #selector(guestButtonTapped), for: .touchUpInside)
        
        view.addSubview(rootLabel)
        view.addSubview(guestbutton)

        NSLayoutConstraint.activate([
            rootLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            rootLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            rootLabel.leftAnchor.constraint(equalTo: view.leftAnchor),
            rootLabel.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            guestbutton.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            guestbutton.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
            guestbutton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -UIScreen.main.bounds.height/4)
        ])
        
        UIView.animate(withDuration: 2) { [weak self] in self?.setNeedsStatusBarAppearanceUpdate() }
        UIView.animate(withDuration: 1) { [weak self] in self?.guestbutton.alpha = 1 }
    }
    
    private func removeLogin(onCompletion: @escaping () -> Void) {
        UIView.animate(withDuration: 1, animations: { [weak self] in
            self?.rootLabel.alpha = 0
            self?.guestbutton.alpha = 0
        }) { [weak self] (complete) in
            self?.rootLabel.removeFromSuperview()
            self?.guestbutton.removeFromSuperview()
            onCompletion()
        }
    }
    
    private func setupViews() {        
        let item = UINavigationItem()
           
        let left = UIButton(type: .custom)
        left.titleLabel?.numberOfLines = 2
        left.setTitle("TRY\nAGAIN", for: .normal)
        left.sizeToFit()
        left.addTarget(self, action: #selector(restart), for: .touchUpInside)
        left.titleLabel?.font = UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: UIFont.Weight.black)
        let tryAgain = UIBarButtonItem(customView: left)
        
        let right = UIButton(type: .custom)
        right.titleLabel?.numberOfLines = 2
        right.titleLabel?.textAlignment = .right
        right.setTitle("TRY\nCHEATING", for: .normal)
        right.sizeToFit()
        right.addTarget(self, action: #selector(cheat), for: .touchUpInside)
        right.titleLabel?.font = UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: UIFont.Weight.black)
        let cheat = UIBarButtonItem(customView: right)
                
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
        cell.font = UIFont(name: "KarmaticArcade", size: UIFont.systemFontSize)
        cell.backgroundColor = .white
        
        switch bleepCount {
        case 0:
            cell.textColor = .black
        case 1:
            cell.textColor = .blue
        case 2:
            cell.textColor = .green
        case 3:
            cell.textColor = .purple
        case 4:
            cell.textColor = .orange
        case 5:
            cell.textColor = .magenta
        case 6:
            cell.textColor = .brown
        case 7:
            cell.textColor = .link
        case 8:
            cell.textColor = .systemIndigo
        default:
            break
        }
        
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
            board[row][column].font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
            board[row][column].text = board[row][column].text == nil ? "☠︎" : nil
        }
    }
}

