// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Foundation

@MainActor
public protocol RootCoordinatorProtocol: AnyObject {
    func start()
    func finishSplash()
    func finishOnboarding()
}
