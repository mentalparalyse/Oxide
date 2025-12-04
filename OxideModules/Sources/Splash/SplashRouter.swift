// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import AppCore

@MainActor
public protocol SplashRouterProtocol {
    func finishSplash()
}

public final class SplashRouter: SplashRouterProtocol {
    
    private weak var coordinator: (any RootCoordinatorProtocol)?
 
    init(coordinator: (any RootCoordinatorProtocol)?) {
        if coordinator == nil { fatalError() }
        self.coordinator = coordinator
    }
 
    
    public func finishSplash() {
        coordinator?.finishSplash()
    }
}

