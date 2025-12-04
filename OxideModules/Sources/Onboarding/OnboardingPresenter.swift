// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Foundation

@MainActor
public final class OnboardingPresenter: ObservableObject {
    private let interactor: OnboardintInteractorProtocol
    private let router: OnboardingRouterProtocol
    
    init(interactor: OnboardintInteractorProtocol, rotuter: OnboardingRouterProtocol) {
        self.interactor = interactor
        self.router = rotuter
    }
    
    public func finish() {
        router.finishOnboarding()
    }
}
