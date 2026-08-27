import AppCore

@MainActor
public enum EditorBuilder {
    public static func makePresenter(
        asset: EditorAsset,
        analytics: any AppAnalyticsTracking,
        onCancel: @escaping @MainActor () -> Void,
        onSave: @escaping @MainActor (EditorAsset) -> Void,
        onError: @escaping @MainActor (String) -> Void
    ) -> EditorPresenter {
        EditorPresenter(
            asset: asset,
            interactor: EditorInteractor(),
            analytics: analytics,
            onCancel: onCancel,
            onSave: onSave,
            onError: onError
        )
    }
}
