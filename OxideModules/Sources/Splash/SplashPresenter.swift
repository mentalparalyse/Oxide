// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Foundation

@MainActor
public final class SplashPresenter: ObservableObject {
    let interactor: SplashInteractorProtocol
    let router: SplashRouterProtocol
    
    init(interactor: SplashInteractorProtocol, router: SplashRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }
    
    func finish() {
        router.finishSplash()
    }
}

