//
//  ListRowViewRotator.swift
//  BitriseATV
//
//  Created by Vladislav Sosiuk on 07.10.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

import Combine

class ListRowViewRotator: ObservableObject {
    @Published var rotation: Double = 0
    
    var shouldRotate: Bool = false {
        didSet {
            if shouldRotate {
                guard cancellables.isEmpty else { return }
                start()
            } else {
                finish()
            }
        }
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    func start() {
        Timer.publish(every: 1 / 360 , on: RunLoop.main, in: .common)
                    .autoconnect()
                    .map { [weak self] _ in
                        guard let self = self else { return 0 }
                        if self.rotation < 360 {
                            return self.rotation + 1
                        }
                        return 0
                    }
                    .sink { [weak self] in self?.rotation = $0 }
                    .store(in: &cancellables)
    }
    
    func finish() {
        cancellables.forEach { $0.cancel() }
        cancellables = []
    }
}
