//
//  Movement.swift
//  MineBleeper
//
//  Created by Wikipedia Brown on 11/10/19.
//  Copyright © 2019 IamGoodBad. All rights reserved.
//

import UIKit


/// Movement is a class that attempts to provide the most precise timer available. It has facilities for start, pause, resume, reset and the ability to call mulitple closures on an interval set by the user. There is normally an initial lag equal to about half of the precision interval set on initlaization.
class Movement {
    
    // MARK: - Open Properties
    open var state: State?
    open var totalTime: TimeInterval { CFAbsoluteTimeGetCurrent() - startTime + sessions.reduce(0) {$0 + $1} }
    
    public enum State {
        case active
        case suspended
    }
    
    // MARK: - Private Properties
    private let queue: DispatchQueue
    private let leeway: DispatchTimeInterval
    private let precision: DispatchTimeInterval
    
    private var activated: Bool { state != nil }
    private var sessions: [TimeInterval] = []
    private var startTime: TimeInterval = .zero
    private var stopTime: TimeInterval = .zero
    private var timer: DispatchSourceTimer?
    private var workItems: [UUID: () -> Void] = [:]
    private var firstTic: Bool = true

    // MARK: - Initializer
    
    /// This initializer has defaults set for all of its parameters.
    /// - Parameters:
    ///   - leeway: 'leeway' is the amount of time that the timer can be allowed drift.
    ///   - precision: 'precision' is the interval between repeating executions of work items.
    ///   - strict: 'strict' is a boolean that is used to determine if teh timer should be strictly observed or not.
    init(leeway: DispatchTimeInterval = .nanoseconds(0),
         precision: DispatchTimeInterval = .seconds(1),
         strict: Bool = true) {
        self.queue = DispatchQueue(label: "com.movement.queue", qos: .background)
        self.leeway = leeway
        self.precision = precision
        if strict {
            self.timer = DispatchSource.makeTimerSource(flags: .strict, queue: queue)
        } else {
            self.timer = DispatchSource.makeTimerSource(queue: queue)
        }
        timer?.schedule(deadline: .now() + precision, repeating: precision, leeway: leeway)
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
        suspend()
    }
    
    func reset() {
        sessions.removeAll()
        suspend()
    }
    
    func resume() {
        guard state != .active else { return }
        state = .active
        startTime = CFAbsoluteTimeGetCurrent()
        timer?.resume()
    }
    
    func start() {
        startTime = CFAbsoluteTimeGetCurrent()
        if activated {
            timer?.resume()
        } else {
            timer?.activate()
        }
        state = .active
    }
    
    // MARK: - Private Functions
    
    private func suspend() {
        guard state != .suspended else { return }
        state = .suspended
        startTime = .zero
        stopTime = CFAbsoluteTimeGetCurrent()
        timer?.suspend()
        firstTic = true
    }
        
    private func tic() {
        if firstTic { firstTic = false; return }
        workItems.values.forEach { $0() }
    }
    
    // MARK: - Deinitializer
    
    deinit {
        sessions.removeAll()
        workItems.removeAll()
        timer?.setEventHandler(handler: nil)
        timer?.cancel()
        resume()
        timer = nil
    }
}
