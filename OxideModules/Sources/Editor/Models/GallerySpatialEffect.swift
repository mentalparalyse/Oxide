import ImageProcessor

extension GalleryEffectKind {
    var supportsSpatialMask: Bool {
        switch self {
        case .lightLeak, .chromaticAberration, .halation, .bloom, .lensWarp, .zoomBlur, .kaleidoscope, .sparkle, .pixelSort, .tiltShift, .edgeBlur, .vignette:
            true
        case .none, .filmGrain, .dustAndScratches, .vhs, .motionBlur:
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
        case .lensWarp: lensWarp.spatialMask
        case .zoomBlur: zoomBlur.spatialMask
        case .kaleidoscope: kaleidoscope.spatialMask
        case .sparkle: sparkle.spatialMask
        case .pixelSort: pixelSort.spatialMask
        case .tiltShift: tiltShift.spatialMask
        case .edgeBlur: edgeBlur.spatialMask
        case .vignette: vignette.spatialMask
        case .none, .filmGrain, .dustAndScratches, .vhs, .motionBlur: nil
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
        case .lensWarp: lensWarp.spatialMask = mask
        case .zoomBlur: zoomBlur.spatialMask = mask
        case .kaleidoscope: kaleidoscope.spatialMask = mask
        case .sparkle: sparkle.spatialMask = mask
        case .pixelSort: pixelSort.spatialMask = mask
        case .tiltShift: tiltShift.spatialMask = mask
        case .edgeBlur: edgeBlur.spatialMask = mask
        case .vignette: vignette.spatialMask = mask
        case .none, .filmGrain, .dustAndScratches, .vhs, .motionBlur: break
        }
    }
}
