import AppCore

#if canImport(AnalyticsCore)
import AnalyticsCore

private struct PrivateAnalyticsTracker: AppAnalyticsTracking {
    let store: any AnalyticsTracking

    func track(_ event: AppAnalyticsEvent) {
        store.track(event.analyticsEvent)
    }

    func setCollectionEnabled(_ isEnabled: Bool) {
        store.setCollectionEnabled(isEnabled)
    }
}

private extension AppAnalyticsEvent {
    var analyticsEvent: AnalyticsEvent {
        switch self {
        case .appStarted: .appStarted
        case .onboardingStarted: .onboardingStarted
        case .onboardingCompleted: .onboardingCompleted
        case .galleryViewed: .galleryViewed
        case .editorStarted(let source): .editorStarted(source: source)
        case .editSaved: .editSaved
        case .editCancelled: .editCancelled
        case .filterApplied(let filterID): .filterApplied(filterID: filterID)
        case .photoExported(let destination): .photoExported(destination: destination)
        case .photoDeleted: .photoDeleted
        case .operationFailed(let operation, let reason):
            .operationFailed(operation: operation, reason: reason)
        }
    }
}
#endif

public final class AnalyticsDependencies: @unchecked Sendable {
    public let tracker: any AppAnalyticsTracking

    public init(tracker: any AppAnalyticsTracking) {
        self.tracker = tracker
    }

    public convenience init() {
        #if canImport(AnalyticsCore)
        self.init(tracker: PrivateAnalyticsTracker(store: AnalyticsStore()))
        #else
        self.init(tracker: NoOpAppAnalyticsTracker())
        #endif
    }
}
