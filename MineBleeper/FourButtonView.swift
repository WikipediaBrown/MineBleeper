//
//  FourButtonView.swift
//  MineBleeper
//
//  Created by Wikipedia Brown on 12/16/19.
//  Copyright © 2019 IamGoodBad. All rights reserved.
//

import UIKit

/// The cases of this enum correspond to the four cartesian quadrants.
enum Quadrant: CaseIterable {
    case one
    case two
    case three
    case four
}


/// Includes four methods corresponding to each quadrant. Methods are called when touches are registerd by the `FourButtonView`.
protocol FourButtonViewDelegate {
    func quadrantITouched(sender: UITapGestureRecognizer)
    func quadrantIITouched(sender: UITapGestureRecognizer)
    func quadrantIIITouched(sender: UITapGestureRecognizer)
    func quadrantIVTouched(sender: UITapGestureRecognizer)
}


/// This view has four quadrants corresponding to the four quadrants of the cartesian plane.
class FourButtonView: UIView {
    
    var delegate: FourButtonViewDelegate?
    
    
    /// Calls the `FourButtonViewDelegate`'s `quadrantITouched(sender: UITapGestureRecognizer)` method.
    /// - Parameter sender: Sender is the `UITapGestureRecognizer` from the button that was touched.
    @objc private func iTouched(sender: UITapGestureRecognizer)  { delegate?.quadrantITouched(sender: sender) }
    
    
    /// Calls the `FourButtonViewDelegate`'s `quadrantITouched(sender: UITapGestureRecognizer)` method.
    /// - Parameter sender: Sender is the `UITapGestureRecognizer` from the button that was touched.
    @objc private func iiTouched(sender: UITapGestureRecognizer) { delegate?.quadrantIITouched(sender: sender) }
    
    
    /// Calls the `FourButtonViewDelegate`'s `quadrantITouched(sender: UITapGestureRecognizer)` method.
    /// - Parameter sender: Sender is the `UITapGestureRecognizer` from the button that was touched.
    @objc private func iiiTapped(sender: UITapGestureRecognizer) { delegate?.quadrantIIITouched(sender: sender) }
    
    
    /// Calls the `FourButtonViewDelegate`'s `quadrantITouched(sender: UITapGestureRecognizer)` method.
    /// - Parameter sender: Sender is the `UITapGestureRecognizer` from the button that was touched.
    @objc private func ivTouched(sender: UITapGestureRecognizer) { delegate?.quadrantIVTouched(sender: sender) }
    
    
    // MARK: Sets up a button for every quadrant.
    override init(frame: CGRect) {
        super.init(frame: frame)
        for quadrant in Quadrant.allCases {
            setupButtons(quadrant: quadrant)
        }
    }
    
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    /// `setupButtons` sets up a button for a given quadrant.
    /// - Parameter quadrant: `quadrant` is a case of the `Quadrant` enum. It determines which button to set up.
    private func setupButtons(quadrant: Quadrant) {

        /// The button to be set up.
        let button: UIButton = getButton()
        
        /// The `backgroundColor` of the button.
        let backgroundColor: UIColor
        
        /// The `topAnchor` of the button.
        let top: NSLayoutYAxisAnchor
        
        /// The `leftAnchor` of the button.
        let left: NSLayoutXAxisAnchor
        
        /// The `bottomAnchor` of the button.
        let bottom: NSLayoutYAxisAnchor
        
        /// The `rightAnchor` of the button.
        let right: NSLayoutXAxisAnchor
        
        // MARK: Uses `quadrant` to determine top and bottom anchors.
        if quadrant == .one || quadrant == .two {
            top = topAnchor
            bottom = centerYAnchor
        } else {
            top = centerYAnchor
            bottom = bottomAnchor
        }
        
        // MARK: Uses `quadrant` to determine left and right anchors.
        if quadrant == .one || quadrant == .four {
            left = centerXAnchor
            right = rightAnchor

        } else {
            left = leftAnchor
            right = centerXAnchor
        }
        
        // MARK: Uses `quadrant` to determine color and `#selector(@objc method)` method.
        switch quadrant {
        case .one:
            backgroundColor = .red
            button.addTarget(self, action: #selector(iTouched), for: .allTouchEvents)
        case .two:
            backgroundColor = .blue
            button.addTarget(self, action: #selector(iTouched), for: .allTouchEvents)
        case .three:
            backgroundColor = .yellow
            button.addTarget(self, action: #selector(iTouched), for: .allTouchEvents)
        case .four:
            backgroundColor = .green
            button.addTarget(self, action: #selector(iTouched), for: .allTouchEvents)
        }
        
        // MARK: Sets `backgroundColor` of button.
        button.backgroundColor = backgroundColor
        
        // MARK: Activates layout constraints.
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: top),
            button.leftAnchor.constraint(equalTo: left),
            button.bottomAnchor.constraint(equalTo: bottom),
            button.rightAnchor.constraint(equalTo: right)
        ])
    }
    
    /// This function returns a `UIButton` that is prepared for setup with auto layout.
    private func getButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
}

