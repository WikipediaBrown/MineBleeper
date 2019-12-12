//
//  GameViewController.swift
//  MineBleeper
//
//  Created by Wikipedia Brown on 12/7/19.
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
    func onAppleLogin()
    func onGuestLogin()
    func onDidAppear()
}

class GameViewController: UIViewController, GamePresentable {
    
    // MARK: - Public Properties

    weak var listener: GameInteractor?
    
    private let boardView = BoardView()
    private let navigationBar = BoardBar()
    private let guestbutton = GuestButton()
    private let rootLabel = RootLabel()
    private let alert = CompletionView()


    
    private var statusBarShouldHide = true
    
    // MARK: - Overriden Properties

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { .slide }
    override var prefersStatusBarHidden: Bool { statusBarShouldHide }

    // MARK: - Overriden Methods
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupLoginViews()
//        listener?.onDidAppear()
    }
    
    func presentError() {
        print("error")
    }
    
    func presentLogin() {
        guestbutton.alpha = 0
        guestbutton.addTarget(self, action: #selector(guestButtonTapped), for: .touchUpInside)
        
        view.addSubview(guestbutton)
        
        var screenHeight: CGFloat
        switch UIDevice.current.userInterfaceIdiom {
        case .pad: screenHeight = -UIScreen.main.bounds.height/2
        case .phone: screenHeight = -UIScreen.main.bounds.height/4
        default: screenHeight = 0
        }
        
        NSLayoutConstraint.activate([
            guestbutton.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            guestbutton.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
            guestbutton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: screenHeight)
        ])
        
        UIView.animate(withDuration: 1) { [weak self] in self?.guestbutton.alpha = 1 }
    }
    
    func presentGame() {
        setupGameViews()
    }
    
    func presentResult(with  bleeps: [IndexPath], and gameState: GameState) {
        let backgroundColor: UIColor
        let textColor: UIColor
        
        switch gameState {
        case .lost: backgroundColor = .red; textColor = .black
        case .won: backgroundColor = Constants.Colors.successGreen; textColor = .white
        default: backgroundColor = .blue; textColor = .white
        }
        
        boardView.displayBleeps(at: bleeps, in: backgroundColor, withTextColor: textColor)
        showCompletion(gameState: gameState)
    }
    
    func showCompletion(gameState: GameState) {
        
        alert.setState(with: gameState)
        alert.center.x = view.center.x
        alert.center.y = view.frame.height + (alert.frame.height / 2)
        
        view.addSubview(alert)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: { [weak self] in
            self?.alert.center = self?.view.center ?? .zero
        }) { (complete) in
        }
        
    }
    
    func dismissCompletion() {
        let center = view.frame.height + (alert.frame.height / 2)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [weak self] in
            self?.alert.center.y = center
        }) { [weak self] (complete) in
            self?.alert.removeFromSuperview()
        }
    }
    
    func presentScore(score: Int) {
        DispatchQueue.main.async { [weak self] in
            let title: String
            if score == 0 {
                title = "!!!Bleep On!!!"
            } else {
                title = "Score: \(score)"
            }
            self?.navigationBar.topItem?.title = title
        }        
    }
    
    func update(indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let tile = listener?.onTileRequest(at: indexPath)
            boardView.updateIndex(with: indexPath, with: tile)
        }
    }
    
    func toggleBleeps(at indexPaths: [IndexPath]) {
        boardView.toggleBleeps(at: indexPaths)
    }
    
    @objc
    func guestButtonTapped() {
        listener?.onGuestLogin()
    }
    
    @objc
    func tryAgainTapped() {
        listener?.onTryAgain()
    }
    
    @objc
    func cheatTapped() {
        listener?.toggleTryCheating()
    }
    
    @objc
    func restart(action: UIAlertAction) {
        tryAgainTapped()
    }
    
    private func setupLoginViews() {
        statusBarShouldHide = !statusBarShouldHide
        
        view.addSubview(rootLabel)

        NSLayoutConstraint.activate([
            rootLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            rootLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            rootLabel.leftAnchor.constraint(equalTo: view.leftAnchor),
            rootLabel.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        UIView.animate(withDuration: 2) { [weak self] in self?.setNeedsStatusBarAppearanceUpdate() }
    }
        
    private func setupGameViews() {
        
        boardView.alpha = 0
        boardView.listener = self
        navigationBar.alpha = 0
        
        listener?.setupBoard()
        boardView.setupGame(rows: listener?.onRowCount(), columns: listener?.onColumnCount())
                
        let left = UIButton(type: .custom)
        let right = UIButton(type: .custom)
        let tryAgain = UIBarButtonItem(customView: left)
        let cheat = UIBarButtonItem(customView: right)
        let item = UINavigationItem()

        left.titleLabel?.numberOfLines = 2
        left.setTitle("TRY\nAGAIN", for: .normal)
        left.sizeToFit()
        left.addTarget(self, action: #selector(tryAgainTapped), for: .touchUpInside)
        left.titleLabel?.font = UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: UIFont.Weight.black)

        right.titleLabel?.numberOfLines = 2
        right.titleLabel?.textAlignment = .right
        right.setTitle("TRY\nCHEATING", for: .normal)
        right.sizeToFit()
        right.addTarget(self, action: #selector(cheatTapped), for: .touchUpInside)
        right.titleLabel?.font = UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: UIFont.Weight.black)

        item.setLeftBarButton(tryAgain, animated: false)
        item.setRightBarButton(cheat, animated: false)
        item.prompt = "WELCOME TO THE THUNDER DEEZY BREEZY"
        item.title = "!!!Bleep On!!!"
        
        navigationBar.pushItem(item, animated: false)
        statusBarShouldHide = false

        view.addSubview(navigationBar)
        view.addSubview(boardView)

        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            navigationBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 78)
        ])

        NSLayoutConstraint.activate([
            boardView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            boardView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            boardView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            boardView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
        ])
        
        UIView.animate(withDuration: 1, animations: { [weak self] in
            self?.rootLabel.alpha = 0
            self?.guestbutton.alpha = 0
        }) { [weak self] (complete) in
            self?.rootLabel.removeFromSuperview()
            self?.guestbutton.removeFromSuperview()
            UIView.animate(withDuration: 2) { [weak self] in self?.boardView.alpha = 1 }
            UIView.animate(withDuration: 3) { [weak self] in self?.navigationBar.alpha = 1 }
        }
    }
}

extension GameViewController: BoardViewListening {
    func numberOfColumns() -> Int { listener?.onColumnCount() ?? 0 }
    func numberOfRows() -> Int { listener?.onRowCount() ?? 0 }
    
    func viewTapped(at column: Int, and row: Int) {
        listener?.onSelectIndex(at: IndexPath(row: row, section: column))
    }
    
    func viewLongPressed(at column: Int, and row: Int) {
        listener?.onToggleFlag(at: IndexPath(row: row, section: column))
    }
}
