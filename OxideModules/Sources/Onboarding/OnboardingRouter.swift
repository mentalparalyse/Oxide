// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import AppCore

@MainActor
public protocol OnboardingRouterProtocol {
    func finishOnboarding()
}

public final class OnboardingRouter: OnboardingRouterProtocol {
    private weak var coordinator: (any RootCoordinatorProtocol)?
    
    init(coordinator: (any RootCoordinatorProtocol)?) {
        if coordinator == nil { fatalError() }
        self.coordinator = coordinator
    }
    
    public func finishOnboarding() {
        coordinator?.finishOnboarding()
    }
}
