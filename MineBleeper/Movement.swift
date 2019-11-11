//
//  Movement.swift
//  MineBleeper
//
//  Created by Wikipedia Brown on 11/10/19.
//  Copyright © 2019 IamGoodBad. All rights reserved.
//

import UIKit


/// Movement is a class that attempts to provide the most precise timer available. It has facilities for start, pause, resume, reset and the ability to call mulitple closures on an interval set by the user.
class Movement {
    
    // MARK: - Private Properties
    
    private let leeway: DispatchTimeInterval
    private let precision: DispatchTimeInterval
//    private let tolerance: DispatchTimeInterval
    
    private var isActive: Bool = false
    private var sessions: [TimeInterval] = []
    private var startTime: TimeInterval = .zero
    private var stopTime: TimeInterval = .zero
    private var timer: DispatchSourceTimer?
    private var totalTime: TimeInterval { startTime + sessions.reduce(0) {$0 + $1} }
    private var workItems: [UUID: () -> Void] = [:]
    
    // MARK: - Initializer
    
    /// The initializer has defaults set for all of its parameters.
    /// - Parameters:
    ///   - leeway: 'leeway' is the amount of time that the timer can be allowed drift.
    ///   - precision: 'precision' is the interval between repeating executions of work items.
    init(leeway: DispatchTimeInterval = .milliseconds(1), precision: DispatchTimeInterval = .seconds(1)) {
        self.leeway = leeway
        self.precision = precision
        self.timer = DispatchSource.makeTimerSource(queue: DispatchQueue(label: "com.movement.queue"))

        timer?.schedule(deadline: .now(), repeating: precision, leeway: leeway)
        timer?.setEventHandler { [weak self] in self?.tic() }
    }
    
    // MARK: - Add/Remove Work Items
    
    func add(workItem: @escaping () -> Void) -> UUID {
        let uuid = UUID()
        workItems[uuid] = workItem
        return uuid
    }
    
    func remove(with uuid: UUID) {
        workItems.removeValue(forKey: uuid)
    }
    
    // MARK: - Pause, Reset, Resume & Start Functions
        
    func pause() {
        sessions.append(startTime - stopTime)
        startTime = .zero
        stopTime = CACurrentMediaTime()
        timer?.suspend()
    }
    
    func reset() {
        sessions.removeAll()
        startTime = .zero
        stopTime = CACurrentMediaTime()
        timer?.suspend()
    }
    
    func resume() {
        startTime = CACurrentMediaTime()
        timer?.resume()
    }
    
    func start() {
        if isActive {
            timer?.resume()
        } else {
            isActive = true
            timer?.activate()
        }
    }
    
    // MARK: - Private Functions
    
    private func tic() {
        workItems.values.forEach { $0() }
    }
    
    // MARK: - Deinitializer
    
    deinit {
        sessions.removeAll()
        timer?.setEventHandler(handler: nil)
        timer?.cancel()
        timer = nil
    }
}
