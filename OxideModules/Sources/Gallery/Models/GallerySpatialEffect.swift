import ImageProcessor

extension GalleryEffectKind {
    var supportsSpatialMask: Bool {
        switch self {
        case .lightLeak, .chromaticAberration, .halation, .bloom:
            true
        case .none, .filmGrain, .dustAndScratches, .vhs:
            false
        }
    }
}

extension ImageEffects {
    func spatialMask(for kind: GalleryEffectKind) -> ImageSpatialEffectMask? {
        switch kind {
        case .lightLeak: lightLeak.spatialMask
        case .chromaticAberration: chromaticAberration.spatialMask
        case .halation: halation.spatialMask
        case .bloom: bloom.spatialMask
        case .none, .filmGrain, .dustAndScratches, .vhs: nil
        }
    }

    mutating func setSpatialMask(
        _ mask: ImageSpatialEffectMask,
        for kind: GalleryEffectKind
    ) {
        switch kind {
        case .lightLeak: lightLeak.spatialMask = mask
        case .chromaticAberration: chromaticAberration.spatialMask = mask
        case .halation: halation.spatialMask = mask
        case .bloom: bloom.spatialMask = mask
        case .none, .filmGrain, .dustAndScratches, .vhs: break
        }
    }
}
