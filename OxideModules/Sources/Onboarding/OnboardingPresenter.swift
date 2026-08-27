// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import AppCore
import Foundation

@MainActor
public final class OnboardingPresenter: ObservableObject {
    @Published var currentPage = 0
    
    let pages: [OnboardingItem]
    
    private let router: OnboardingRouterProtocol
    private let analytics: any AppAnalyticsTracking
    
    init(interactor: OnboardingInteractorProtocol, router: OnboardingRouterProtocol, analytics: any AppAnalyticsTracking = NoOpAppAnalyticsTracker()) {
        self.pages = interactor.fetchPages()
        self.router = router
        self.analytics = analytics
        analytics.track(.onboardingStarted)
    }
    
    public func finish() {
        analytics.track(.onboardingCompleted)
        router.finishOnboarding()
    }
}
