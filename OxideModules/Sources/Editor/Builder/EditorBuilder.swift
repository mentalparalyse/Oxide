@MainActor
public enum EditorBuilder {
    public static func makePresenter(
        asset: EditorAsset,
        onCancel: @escaping @MainActor () -> Void,
        onSave: @escaping @MainActor (EditorAsset) -> Void,
        onError: @escaping @MainActor (String) -> Void
    ) -> EditorPresenter {
        EditorPresenter(
            asset: asset,
            interactor: EditorInteractor(),
            onCancel: onCancel,
            onSave: onSave,
            onError: onError
        )
    }
}
