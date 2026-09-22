import AppCore

@MainActor
public enum EditorBuilder {
    static func makeLooksPresenter(
        draft: EditorDraft,
        onApply: @escaping @MainActor (SavedLook) async throws -> Void,
        onClose: @escaping @MainActor () -> Void
    ) -> SavedLooksPresenter {
        SavedLooksPresenter(
            draft: draft,
            interactor: SavedLooksInteractor(store: .shared),
            onApply: onApply,
            onClose: onClose
        )
    }

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
