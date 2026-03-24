// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Foundation

@MainActor
public final class OnboardingPresenter: ObservableObject {
    @Published var currentPage = 0
    
    let pages: [OnboardingItem]
    
    private let router: OnboardingRouterProtocol
    
    init(interactor: OnboardingInteractorProtocol, router: OnboardingRouterProtocol) {
        self.pages = interactor.fetchPages()
        self.router = router
    }
    
    public func finish() {
        router.finishOnboarding()
    }
}
