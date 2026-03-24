// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Foundation
 
@MainActor
protocol OnboardingInteractorProtocol {
    func fetchPages() -> [OnboardingItem]
}

final class OnboardingInteractor: OnboardingInteractorProtocol {
    init() { }
    
    func fetchPages() -> [OnboardingItem] {
        [
            .init(
                imageName: "ic_camera",
                title: "Capture",
                description: "Capture moments in one tap"
            ),
            .init(
                imageName: "ic_sliders",
                title: "Edit",
                description: "Perfect with filters & tools"
            ),
            .init(
                imageName: "ic_folder-open",
                title: "Organize",
                description: "Your photos, stored locally"
            )
        ]
    }
}
