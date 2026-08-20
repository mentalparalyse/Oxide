import ImageProcessor

enum GalleryEffectKind: String, Sendable {
    case none
    case filmGrain
    case lightLeak
    case chromaticAberration
    case halation
    case dustAndScratches
    case bloom
    case vhs
    case lensWarp
    case motionBlur
    case zoomBlur
    case kaleidoscope
}

struct GalleryEffectPreset: Identifiable, Sendable {
    let id: String
    let name: String
    let kind: GalleryEffectKind
    let previewEffects: ImageEffects

    var isNone: Bool { kind == .none }

    func applying(to current: ImageEffects) -> ImageEffects {
        guard !isNone else { return .neutral }
        var result = current
        switch kind {
        case .none:
            return .neutral
        case .filmGrain:
            result.filmGrain = previewEffects.filmGrain
        case .lightLeak:
            result.lightLeak = previewEffects.lightLeak
        case .chromaticAberration:
            result.chromaticAberration = previewEffects.chromaticAberration
        case .halation:
            result.halation = previewEffects.halation
        case .dustAndScratches:
            result.dustAndScratches = previewEffects.dustAndScratches
        case .bloom:
            result.bloom = previewEffects.bloom
        case .vhs:
            result.vhs = previewEffects.vhs
        case .lensWarp:
            result.lensWarp = previewEffects.lensWarp
        case .motionBlur:
            result.motionBlur = previewEffects.motionBlur
        case .zoomBlur:
            result.zoomBlur = previewEffects.zoomBlur
        case .kaleidoscope:
            result.kaleidoscope = previewEffects.kaleidoscope
        }
        return result
    }

    static func initialSelectionID(for effects: ImageEffects) -> ID {
        if effects.kaleidoscope.isEnabled { return "kaleido-mirror" }
        if effects.zoomBlur.isEnabled { return "zoom-rush" }
        if effects.motionBlur.isEnabled { return "motion-soft" }
        if effects.lensWarp.isEnabled { return "lens-fisheye" }
        if effects.vhs.isEnabled { return "vhs-clean" }
        if effects.bloom.isEnabled { return "bloom-soft" }
        if effects.dustAndScratches.isEnabled { return "dust-clean" }
        if effects.halation.isEnabled { return "halation-soft" }
        if effects.chromaticAberration.amount > 0 { return "chromatic-soft" }
        if effects.lightLeak.amount > 0 { return "leak-left" }
        if effects.filmGrain.isEnabled { return "grain-fine" }
        return "none"
    }

    static let all: [GalleryEffectPreset] = [
        GalleryEffectPreset(id: "none", name: "None", kind: .none, previewEffects: .neutral),
        GalleryEffectPreset(
            id: "grain-fine",
            name: "Fine",
            kind: .filmGrain,
            previewEffects: ImageEffects(filmGrain: ImageFilmGrain(amount: 0.32, size: 0.65))
        ),
        GalleryEffectPreset(
            id: "grain-film",
            name: "Film",
            kind: .filmGrain,
            previewEffects: ImageEffects(filmGrain: ImageFilmGrain(amount: 0.55, size: 1.4))
        ),
        GalleryEffectPreset(
            id: "leak-left",
            name: "Warm L",
            kind: .lightLeak,
            previewEffects: ImageEffects(lightLeak: ImageLightLeak(amount: 0.62, position: 0.12, warmth: 0.95))
        ),
        GalleryEffectPreset(
            id: "leak-right",
            name: "Warm R",
            kind: .lightLeak,
            previewEffects: ImageEffects(lightLeak: ImageLightLeak(amount: 0.62, position: 0.88, warmth: 0.95))
        ),
        GalleryEffectPreset(
            id: "leak-pink",
            name: "Pink",
            kind: .lightLeak,
            previewEffects: ImageEffects(lightLeak: ImageLightLeak(amount: 0.55, position: 0.2, warmth: 0.15))
        ),
        GalleryEffectPreset(
            id: "chromatic-soft",
            name: "Prism",
            kind: .chromaticAberration,
            previewEffects: ImageEffects(chromaticAberration: ImageChromaticAberration(amount: 0.35, falloff: 0.65))
        ),
        GalleryEffectPreset(
            id: "chromatic-diagonal",
            name: "Shift",
            kind: .chromaticAberration,
            previewEffects: ImageEffects(chromaticAberration: ImageChromaticAberration(amount: 0.55, direction: 0.125, falloff: 0.45))
        ),
        GalleryEffectPreset(
            id: "halation-soft",
            name: "Halo",
            kind: .halation,
            previewEffects: ImageEffects(halation: ImageHalation(amount: 0.42, radius: 0.45, threshold: 0.72))
        ),
        GalleryEffectPreset(
            id: "halation-dream",
            name: "Dream",
            kind: .halation,
            previewEffects: ImageEffects(halation: ImageHalation(amount: 0.68, radius: 0.72, threshold: 0.55))
        ),
        GalleryEffectPreset(
            id: "dust-clean",
            name: "Clean Dust",
            kind: .dustAndScratches,
            previewEffects: ImageEffects(dustAndScratches: ImageDustAndScratches(amount: 0.38, dustAmount: 0.7, scratchAmount: 0.05, particleSize: 0.3, seed: 11))
        ),
        GalleryEffectPreset(
            id: "dust-archive",
            name: "Archive",
            kind: .dustAndScratches,
            previewEffects: ImageEffects(dustAndScratches: ImageDustAndScratches(amount: 0.55, dustAmount: 0.65, scratchAmount: 0.4, particleSize: 0.48, seed: 37))
        ),
        GalleryEffectPreset(
            id: "dust-damaged",
            name: "Damaged",
            kind: .dustAndScratches,
            previewEffects: ImageEffects(dustAndScratches: ImageDustAndScratches(amount: 0.78, dustAmount: 0.85, scratchAmount: 0.75, particleSize: 0.62, seed: 73))
        ),
        GalleryEffectPreset(
            id: "bloom-soft",
            name: "Bloom",
            kind: .bloom,
            previewEffects: ImageEffects(bloom: ImageBloom(amount: 0.38, radius: 0.42, threshold: 0.52, warmth: 0.5))
        ),
        GalleryEffectPreset(
            id: "bloom-dream",
            name: "Dream",
            kind: .bloom,
            previewEffects: ImageEffects(bloom: ImageBloom(amount: 0.62, radius: 0.7, threshold: 0.3, warmth: 0.72))
        ),
        GalleryEffectPreset(
            id: "bloom-neon",
            name: "Neon",
            kind: .bloom,
            previewEffects: ImageEffects(bloom: ImageBloom(amount: 0.7, radius: 0.32, threshold: 0.64, warmth: 0.18))
        ),
        GalleryEffectPreset(
            id: "vhs-clean",
            name: "VHS",
            kind: .vhs,
            previewEffects: ImageEffects(vhs: ImageVHS(amount: 0.42, distortion: 0.28, scanlines: 0.38, colorBleed: 0.3, seed: 7))
        ),
        GalleryEffectPreset(
            id: "vhs-tracking",
            name: "Tracking",
            kind: .vhs,
            previewEffects: ImageEffects(vhs: ImageVHS(amount: 0.68, distortion: 0.82, scanlines: 0.55, colorBleed: 0.44, seed: 19))
        ),
        GalleryEffectPreset(
            id: "vhs-rgb",
            name: "RGB Tape",
            kind: .vhs,
            previewEffects: ImageEffects(vhs: ImageVHS(amount: 0.72, distortion: 0.4, scanlines: 0.32, colorBleed: 0.88, seed: 31))
        ),
        GalleryEffectPreset(
            id: "lens-fisheye",
            name: "Fisheye",
            kind: .lensWarp,
            previewEffects: ImageEffects(lensWarp: ImageLensWarp(amount: 0.68, scale: 0.72))
        ),
        GalleryEffectPreset(
            id: "lens-bulge",
            name: "Bulge",
            kind: .lensWarp,
            previewEffects: ImageEffects(lensWarp: ImageLensWarp(amount: 0.45, scale: 0.45))
        ),
        GalleryEffectPreset(
            id: "lens-pinch",
            name: "Pinch",
            kind: .lensWarp,
            previewEffects: ImageEffects(lensWarp: ImageLensWarp(amount: 0.62, scale: -0.65))
        ),
        GalleryEffectPreset(id: "motion-soft", name: "Motion", kind: .motionBlur, previewEffects: ImageEffects(motionBlur: ImageMotionBlur(amount: 0.38, distance: 0.32))),
        GalleryEffectPreset(id: "motion-speed", name: "Speed", kind: .motionBlur, previewEffects: ImageEffects(motionBlur: ImageMotionBlur(amount: 0.68, distance: 0.78))),
        GalleryEffectPreset(id: "motion-diagonal", name: "Diagonal", kind: .motionBlur, previewEffects: ImageEffects(motionBlur: ImageMotionBlur(amount: 0.55, distance: 0.55, angle: 0.125))),
        GalleryEffectPreset(id: "zoom-rush", name: "Rush", kind: .zoomBlur, previewEffects: ImageEffects(zoomBlur: ImageZoomBlur(amount: 0.38, strength: 0.35))),
        GalleryEffectPreset(id: "zoom-impact", name: "Impact", kind: .zoomBlur, previewEffects: ImageEffects(zoomBlur: ImageZoomBlur(amount: 0.62, strength: 0.62))),
        GalleryEffectPreset(id: "zoom-warp", name: "Warp", kind: .zoomBlur, previewEffects: ImageEffects(zoomBlur: ImageZoomBlur(amount: 0.82, strength: 0.88))),
        GalleryEffectPreset(id: "kaleido-mirror", name: "Mirror", kind: .kaleidoscope, previewEffects: ImageEffects(kaleidoscope: ImageKaleidoscope(amount: 0.55, segments: 2))),
        GalleryEffectPreset(id: "kaleido-crystal", name: "Crystal", kind: .kaleidoscope, previewEffects: ImageEffects(kaleidoscope: ImageKaleidoscope(amount: 0.72, segments: 6, rotation: 0.08))),
        GalleryEffectPreset(id: "kaleido-prism", name: "Prism", kind: .kaleidoscope, previewEffects: ImageEffects(kaleidoscope: ImageKaleidoscope(amount: 0.82, segments: 8, rotation: 0.18))),
        GalleryEffectPreset(id: "kaleido-portal", name: "Portal", kind: .kaleidoscope, previewEffects: ImageEffects(kaleidoscope: ImageKaleidoscope(amount: 0.9, segments: 12, rotation: 0.32)))
    ]
}
