import ImageProcessor

extension GalleryEffectPreset {
    static func initialSelectionID(for effects: ImageEffects) -> ID {
        if effects.lensDirt.isEnabled { return "dirt-clean" }
        if effects.softFocus.isEnabled { return "focus-classic" }
        if effects.dreamGlow.isEnabled { return "glow-portrait" }
        if effects.lensFlare.isEnabled { return "flare-cinematic" }
        if effects.vignette.isEnabled { return "vignette-dark" }
        if effects.edgeBlur.isEnabled { return "edge-soft" }
        if effects.tiltShift.isEnabled { return "tilt-miniature" }
        if effects.pixelSort.isEnabled { return "sort-clean" }
        if effects.sparkle.isEnabled { return "sparkle-soft" }
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
}
