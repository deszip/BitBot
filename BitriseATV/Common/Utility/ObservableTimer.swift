//
//  ObservableTimer.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 07.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import Combine

class ObservableTimer: ObservableObject {
    var action: (() -> Void)?
    
    var objectWillChange = ObservableObjectPublisher()
    
    private let timeInterval: TimeInterval
    private var cancellables: Set<AnyCancellable> = []
    
    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }
    
    func start() {
        guard cancellables.isEmpty else { return }
        Timer.publish(every: timeInterval,
                      on: RunLoop.main,
                      in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.action?()
            }
            .store(in: &cancellables)
    }
    
    func finish() {
        cancellables.forEach { $0.cancel() }
        cancellables = [] 
    }
}
