//
//  ObservableTimer.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 07.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import Combine

class ObservableTimer<T: Equatable>: ObservableObject {
    @Published var value: T
    
    private let initialValue: T
    private let timeInterval: TimeInterval
    private let action: (T) -> T
    private var cancellables: Set<AnyCancellable> = []
    
    init(initialValue: T,
         timeInterval: TimeInterval,
         action: @escaping (T) -> T) {
        self.value = initialValue
        self.initialValue = initialValue
        self.timeInterval = timeInterval
        self.action = action
    }
    
    func start() {
        guard cancellables.isEmpty else { return }
        Timer.publish(every: timeInterval,
                      on: RunLoop.main,
                      in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.value = self.action(self.value)
            }
            .store(in: &cancellables)
    }
    
    func finish() {
        cancellables.forEach { $0.cancel() }
        cancellables = []
        
        if value != initialValue {
            value = initialValue
        }
    }
}
