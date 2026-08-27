public enum AppAnalyticsEvent: Sendable, Equatable {
    case appStarted
    case onboardingStarted
    case onboardingCompleted
    case galleryViewed
    case editorStarted(source: String)
    case editSaved
    case editCancelled
    case filterApplied(filterID: String)
    case photoExported(destination: String)
    case photoDeleted
    case operationFailed(operation: String, reason: String)
}

public protocol AppAnalyticsTracking: Sendable {
    func track(_ event: AppAnalyticsEvent)
    func setCollectionEnabled(_ isEnabled: Bool)
}

public struct NoOpAppAnalyticsTracker: AppAnalyticsTracking {
    public init() {}
    public func track(_ event: AppAnalyticsEvent) {}
    public func setCollectionEnabled(_ isEnabled: Bool) {}
}
