import ImageProcessor

extension GalleryEffectPreset {
    func applying(to current: ImageEffects) -> ImageEffects {
        guard !isNone else { return .neutral }
        var result = current
        switch kind {
        case .none: return .neutral
        case .filmGrain:
            result.filmGrain = previewEffects.filmGrain
            result.filmGrain.amount = 1
        case .lightLeak:
            result.lightLeak = previewEffects.lightLeak
            result.lightLeak.amount = 1
        case .chromaticAberration:
            result.chromaticAberration = previewEffects.chromaticAberration
            result.chromaticAberration.amount = 1
        case .halation:
            result.halation = previewEffects.halation
            result.halation.amount = 1
        case .dustAndScratches:
            result.dustAndScratches = previewEffects.dustAndScratches
            result.dustAndScratches.amount = 1
        case .bloom:
            result.bloom = previewEffects.bloom
            result.bloom.amount = 1
        case .vhs:
            result.vhs = previewEffects.vhs
            result.vhs.amount = 1
        case .lensWarp:
            result.lensWarp = previewEffects.lensWarp
            result.lensWarp.amount = 1
        case .motionBlur:
            result.motionBlur = previewEffects.motionBlur
            result.motionBlur.amount = 1
        case .zoomBlur:
            result.zoomBlur = previewEffects.zoomBlur
            result.zoomBlur.amount = 1
        case .kaleidoscope:
            result.kaleidoscope = previewEffects.kaleidoscope
            result.kaleidoscope.amount = 1
        case .sparkle:
            result.sparkle = previewEffects.sparkle
            result.sparkle.amount = 1
        case .pixelSort:
            result.pixelSort = previewEffects.pixelSort
            result.pixelSort.amount = 1
        case .tiltShift:
            result.tiltShift = previewEffects.tiltShift
            result.tiltShift.amount = 1
        case .edgeBlur:
            result.edgeBlur = previewEffects.edgeBlur
            result.edgeBlur.amount = 1
        case .vignette:
            result.vignette = previewEffects.vignette
            result.vignette.amount = 1
        case .lensDirt:
            result.lensDirt = previewEffects.lensDirt
            result.lensDirt.amount = 1
        case .softFocus:
            result.softFocus = previewEffects.softFocus
            result.softFocus.amount = 1
        case .dreamGlow:
            result.dreamGlow = previewEffects.dreamGlow
            result.dreamGlow.amount = 1
        case .lensFlare:
            result.lensFlare = previewEffects.lensFlare
            result.lensFlare.amount = 1
        }
        return result
    }

    func removing(from current: ImageEffects) -> ImageEffects {
        var result = current
        switch kind {
        case .none: return .neutral
        case .filmGrain: result.filmGrain = .disabled
        case .lightLeak: result.lightLeak = .disabled
        case .chromaticAberration: result.chromaticAberration = .disabled
        case .halation: result.halation = .disabled
        case .dustAndScratches: result.dustAndScratches = .disabled
        case .bloom: result.bloom = .disabled
        case .vhs: result.vhs = .disabled
        case .lensWarp: result.lensWarp = .disabled
        case .motionBlur: result.motionBlur = .disabled
        case .zoomBlur: result.zoomBlur = .disabled
        case .kaleidoscope: result.kaleidoscope = .disabled
        case .sparkle: result.sparkle = .disabled
        case .pixelSort: result.pixelSort = .disabled
        case .tiltShift: result.tiltShift = .disabled
        case .edgeBlur: result.edgeBlur = .disabled
        case .vignette: result.vignette = .disabled
        case .lensDirt: result.lensDirt = .disabled
        case .softFocus: result.softFocus = .disabled
        case .dreamGlow: result.dreamGlow = .disabled
        case .lensFlare: result.lensFlare = .disabled
        }
        return result
    }
}
