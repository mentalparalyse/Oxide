// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Foundation

@MainActor
protocol HomeInteractorProtocol {
    func defaultTab() -> Tab
}

final class HomeInteractor: HomeInteractorProtocol {
    init() { }

    func defaultTab() -> Tab {
        .gallery
    }
}
