// Copyright (c) 2025 SoftFusion. All rights reserved.

public enum GalleryScreen: Equatable {
    case gallery
    case preview(GalleryPhoto.ID)
    case capture
    case editing(GalleryPhoto.ID)
}

public enum GalleryToast: Equatable {
    case success(String)
    case error(String)

    public var message: String {
        switch self {
        case .success(let message), .error(let message):
            return message
        }
    }
}

public enum GalleryPreviewSaveState: Equatable {
    case idle
    case saving
    case saved
}
