//
//  GameViewController.swift
//  MineBleeper
//
//  Created by Wikipedia Brown on 12/7/19.
//  Copyright © 2019 IamGoodBad. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, GamePresentable {

    weak var listener: GameInteractor?
    
    private let boardView = BoardView()
    private let navigationBar = BoardBar()
    
    private var statusBarShouldHide = true
    
    // MARK: - Overriden Properties

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { .slide }
    override var prefersStatusBarHidden: Bool { statusBarShouldHide }

    // MARK: - Overriden Methods
    
    override func viewDidLoad() { super.viewDidLoad(); setupViews() }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        listener?.setupBoard()
        boardView.setupGame(rows: listener?.onRowCount(), columns: listener?.onColumnCount())

    }
    
    func presentError() {
        print("error")
    }
    
    func presentLoss() {
        print("lost")
    }
    
    func presentWin() {
        print("won")
    }
    
    func presentScore(score: Int) {
        print(score)
    }
    
    func update(indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let tile = listener?.onTileRequest(at: indexPath)
            boardView.updateIndex(with: indexPath, with: tile)
        }
    }
    
    @objc
    func tryAgainTapped() {
        listener?.onTryAgain()
    }
    
    @objc
    func cheatTapped() {
        listener?.toggleTryCheating()
    }
        
    private func setupViews() {
        navigationBar.alpha = 1
        
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

        item.setLeftBarButton(tryAgain, animated: true)
        item.setRightBarButton(cheat, animated: true)

        view.addSubview(boardView)
        view.addSubview(navigationBar)

        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            navigationBar.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])

        NSLayoutConstraint.activate([
            boardView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            boardView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            boardView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            boardView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
        ])
        
        navigationBar.pushItem(item, animated: true)
        statusBarShouldHide = false
    }
}
