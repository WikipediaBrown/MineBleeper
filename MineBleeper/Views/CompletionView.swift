//
//  WinView.swift
//  MineBleeper
//
//  Created by Wikipedia Brown on 12/9/19.
//  Copyright © 2019 IamGoodBad. All rights reserved.
//

import UIKit

class CompletionView: UIView {
    
    private let screenSize = UIScreen.main.bounds.size
    private let height: CGFloat
    private let width: CGFloat
    private let borderWidth: CGFloat = 7
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: UIFont.buttonFontSize * 2, weight: .black)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bodyTextView: UITextView = {
        let textView = UITextView()
        textView.isUserInteractionEnabled = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.font = UIFont.preferredFont(forTextStyle: .title2)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let expandButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: UIFont.buttonFontSize, weight: .black)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    func setState(with gameState: GameState) {
        switch gameState {
        case .lost:
            backgroundColor = .red
            titleLabel.text = "Bleep Thiiiiis..."
            bodyTextView.text = "You've Lost... you shouldn't do that my dudes..."
            titleLabel.textColor = .black
            bodyTextView.textColor = .black
            layer.borderColor = UIColor.black.cgColor
            expandButton.layer.borderWidth = borderWidth
            expandButton.layer.borderColor = UIColor.black.cgColor
            expandButton.setTitle("Try Again Loser", for: .normal)
            expandButton.setTitleColor(.black, for: .normal)
        case .won:
            backgroundColor = Constants.Colors.successGreen
            titleLabel.text = "You did iiiiit..."
            bodyTextView.text = "yaaaay..."
            titleLabel.textColor = .darkGray
            bodyTextView.textColor = .darkGray
            layer.borderColor = UIColor.darkGray.cgColor
            expandButton.layer.borderWidth = borderWidth
            expandButton.layer.borderColor = UIColor.darkGray.cgColor
            expandButton.setTitle("!!!DO IT AGAIN!!!", for: .normal)
            expandButton.setTitleColor(.darkGray, for: .normal)
        default:
            backgroundColor = .blue
            titleLabel.text = nil
            titleLabel.textColor = nil
            bodyTextView.text = nil
            expandButton.setTitle(nil, for: .normal)
        }
    }
    
    init() {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone: height = screenSize.height/4; width = screenSize.width - 20
        default: height = 300; width = 400
        }
        
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: width, height: height)))

        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        layer.cornerRadius = 30
        layer.borderWidth = borderWidth
        layer.shadowRadius = 10
        clipsToBounds = true
        
        addSubview(titleLabel)
        addSubview(bodyTextView)
        addSubview(expandButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            titleLabel.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor),
            titleLabel.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: height / 6)
        ])
        
        NSLayoutConstraint.activate([
            bodyTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            bodyTextView.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor),
            bodyTextView.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor),
            bodyTextView.bottomAnchor.constraint(equalTo: expandButton.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            expandButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            expandButton.leftAnchor.constraint(equalTo: leftAnchor),
            expandButton.rightAnchor.constraint(equalTo: rightAnchor),
            expandButton.heightAnchor.constraint(equalToConstant: height / 5)
        ])
    }
}
