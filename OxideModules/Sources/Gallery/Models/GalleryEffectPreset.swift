import ImageProcessor

enum GalleryEffectKind: String, Sendable {
    case none
    case filmGrain
    case lightLeak
    case chromaticAberration
    case halation
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
        }
        return result
    }

    static func initialSelectionID(for effects: ImageEffects) -> ID {
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
        )
    ]
}
