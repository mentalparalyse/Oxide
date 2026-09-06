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
    case sparkle
    case pixelSort
    case tiltShift
    case edgeBlur
    case vignette
    case lensDirt
    case softFocus
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
        }
        return result
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
        GalleryEffectPreset(id: "kaleido-portal", name: "Portal", kind: .kaleidoscope, previewEffects: ImageEffects(kaleidoscope: ImageKaleidoscope(amount: 0.9, segments: 12, rotation: 0.32))),
        GalleryEffectPreset(id: "sparkle-soft", name: "Soft Sparkle", kind: .sparkle, previewEffects: ImageEffects(sparkle: ImageSparkle(amount: 0.4, threshold: 0.78, rayLength: 0.28))),
        GalleryEffectPreset(id: "sparkle-starburst", name: "Starburst", kind: .sparkle, previewEffects: ImageEffects(sparkle: ImageSparkle(amount: 0.72, threshold: 0.62, rayLength: 0.72))),
        GalleryEffectPreset(id: "sparkle-dream", name: "Dream Glitter", kind: .sparkle, previewEffects: ImageEffects(sparkle: ImageSparkle(amount: 0.58, threshold: 0.48, rayLength: 0.42, rotation: 0.125))),
        GalleryEffectPreset(id: "sparkle-neon", name: "Neon Glints", kind: .sparkle, previewEffects: ImageEffects(sparkle: ImageSparkle(amount: 0.86, threshold: 0.7, rayLength: 0.88, rotation: 0.25))),
        GalleryEffectPreset(id: "sort-clean", name: "Clean Sort", kind: .pixelSort, previewEffects: ImageEffects(pixelSort: ImagePixelSort(amount: 0.38, threshold: 0.72, trailLength: 0.3, direction: 0.25))),
        GalleryEffectPreset(id: "sort-melt", name: "Melt", kind: .pixelSort, previewEffects: ImageEffects(pixelSort: ImagePixelSort(amount: 0.68, threshold: 0.5, trailLength: 0.72, direction: 0.25))),
        GalleryEffectPreset(id: "sort-neon", name: "Neon Drag", kind: .pixelSort, previewEffects: ImageEffects(pixelSort: ImagePixelSort(amount: 0.76, threshold: 0.68, trailLength: 0.82, direction: 0))),
        GalleryEffectPreset(id: "sort-rupture", name: "Digital Rupture", kind: .pixelSort, previewEffects: ImageEffects(pixelSort: ImagePixelSort(amount: 0.92, threshold: 0.34, trailLength: 0.94, direction: 0.625))),
        GalleryEffectPreset(id: "tilt-miniature", name: "Miniature", kind: .tiltShift, previewEffects: ImageEffects(tiltShift: ImageTiltShift(amount: 0.7, blur: 0.72, style: .linear, spatialMask: ImageSpatialEffectMask(mode: .spot, radius: 0.22, feather: 0.55)))),
        GalleryEffectPreset(id: "tilt-portrait", name: "Portrait Band", kind: .tiltShift, previewEffects: ImageEffects(tiltShift: ImageTiltShift(amount: 0.52, blur: 0.48, style: .linear, rotation: 0.5, spatialMask: ImageSpatialEffectMask(mode: .spot, radius: 0.34, feather: 0.7)))),
        GalleryEffectPreset(id: "tilt-radial", name: "Radial Focus", kind: .tiltShift, previewEffects: ImageEffects(tiltShift: ImageTiltShift(amount: 0.68, blur: 0.62, style: .radial, spatialMask: ImageSpatialEffectMask(mode: .spot, radius: 0.3, feather: 0.52)))),
        GalleryEffectPreset(id: "tilt-dream", name: "Dream Slice", kind: .tiltShift, previewEffects: ImageEffects(tiltShift: ImageTiltShift(amount: 0.82, blur: 0.84, style: .linear, rotation: 0.08, spatialMask: ImageSpatialEffectMask(mode: .spot, centerY: 0.44, radius: 0.18, feather: 0.8)))),
        GalleryEffectPreset(id: "edge-soft", name: "Soft Edge", kind: .edgeBlur, previewEffects: ImageEffects(edgeBlur: ImageEdgeBlur(amount: 0.48, blur: 0.52, shape: .oval, spatialMask: ImageSpatialEffectMask(mode: .spot, radius: 0.48, feather: 0.62)))),
        GalleryEffectPreset(id: "edge-portrait", name: "Portrait", kind: .edgeBlur, previewEffects: ImageEffects(edgeBlur: ImageEdgeBlur(amount: 0.68, blur: 0.66, shape: .oval, spatialMask: ImageSpatialEffectMask(mode: .spot, centerY: 0.44, radius: 0.34, feather: 0.72)))),
        GalleryEffectPreset(id: "edge-frame", name: "Soft Frame", kind: .edgeBlur, previewEffects: ImageEffects(edgeBlur: ImageEdgeBlur(amount: 0.62, blur: 0.58, shape: .frame, spatialMask: ImageSpatialEffectMask(mode: .spot, radius: 0.58, feather: 0.5)))),
        GalleryEffectPreset(id: "edge-dream", name: "Dream Edge", kind: .edgeBlur, previewEffects: ImageEffects(edgeBlur: ImageEdgeBlur(amount: 0.86, blur: 0.84, shape: .oval, spatialMask: ImageSpatialEffectMask(mode: .spot, radius: 0.28, feather: 0.86)))),
        GalleryEffectPreset(id: "vignette-dark", name: "Dark", kind: .vignette, previewEffects: ImageEffects(vignette: ImageVignette(amount: 0.58, size: 0.56, feather: 0.7, roundness: 0.55, spatialMask: ImageSpatialEffectMask(mode: .spot)))),
        GalleryEffectPreset(id: "vignette-bright", name: "Bright", kind: .vignette, previewEffects: ImageEffects(vignette: ImageVignette(amount: 0.34, size: 0.62, feather: 0.82, roundness: 0.48, color: .white, spatialMask: ImageSpatialEffectMask(mode: .spot)))),
        GalleryEffectPreset(id: "vignette-color", name: "Color", kind: .vignette, previewEffects: ImageEffects(vignette: ImageVignette(amount: 0.46, size: 0.52, feather: 0.68, roundness: 0.62, color: .init(red: 0.34, green: 0.08, blue: 0.42), spatialMask: ImageSpatialEffectMask(mode: .spot)))),
        GalleryEffectPreset(id: "vignette-aged", name: "Aged", kind: .vignette, previewEffects: ImageEffects(vignette: ImageVignette(amount: 0.68, size: 0.48, feather: 0.56, roundness: 0.28, irregularity: 0.72, color: .init(red: 0.16, green: 0.08, blue: 0.03), spatialMask: ImageSpatialEffectMask(mode: .spot)))),
        GalleryEffectPreset(id: "dirt-clean", name: "Clean Glass", kind: .lensDirt, previewEffects: ImageEffects(lensDirt: ImageLensDirt(amount: 0.3, density: 0.2, smudge: 0.16, flare: 0.22, seed: 7, spatialMask: ImageSpatialEffectMask(mode: .spot, radius: 0.7, feather: 0.8)))),
        GalleryEffectPreset(id: "dirt-smudged", name: "Smudged", kind: .lensDirt, previewEffects: ImageEffects(lensDirt: ImageLensDirt(amount: 0.58, density: 0.2, smudge: 0.8, flare: 0.36, seed: 19, spatialMask: ImageSpatialEffectMask(mode: .spot, radius: 0.62, feather: 0.72)))),
        GalleryEffectPreset(id: "dirt-dusty", name: "Dusty Lens", kind: .lensDirt, previewEffects: ImageEffects(lensDirt: ImageLensDirt(amount: 0.64, density: 0.84, smudge: 0.28, flare: 0.2, seed: 43, spatialMask: ImageSpatialEffectMask(mode: .spot, radius: 0.78, feather: 0.62)))),
        GalleryEffectPreset(id: "dirt-flare", name: "Flare Spots", kind: .lensDirt, previewEffects: ImageEffects(lensDirt: ImageLensDirt(amount: 0.72, density: 0.35, smudge: 0.58, flare: 0.9, seed: 71, spatialMask: ImageSpatialEffectMask(mode: .spot, radius: 0.56, feather: 0.84)))),
        GalleryEffectPreset(id: "focus-classic", name: "Classic", kind: .softFocus, previewEffects: ImageEffects(softFocus: ImageSoftFocus(amount: 1, softness: 0.45, glow: 0.28, detail: 0.72))),
        GalleryEffectPreset(id: "focus-portrait", name: "Portrait", kind: .softFocus, previewEffects: ImageEffects(softFocus: ImageSoftFocus(amount: 1, softness: 0.34, glow: 0.2, detail: 0.86, spatialMask: ImageSpatialEffectMask(mode: .spot, radius: 0.5, feather: 0.78)))),
        GalleryEffectPreset(id: "focus-dream", name: "Dreamy", kind: .softFocus, previewEffects: ImageEffects(softFocus: ImageSoftFocus(amount: 1, softness: 0.75, glow: 0.68, detail: 0.42))),
        GalleryEffectPreset(id: "focus-silk", name: "Silk", kind: .softFocus, previewEffects: ImageEffects(softFocus: ImageSoftFocus(amount: 1, softness: 0.58, glow: 0.4, detail: 0.58)))
    ]
}
