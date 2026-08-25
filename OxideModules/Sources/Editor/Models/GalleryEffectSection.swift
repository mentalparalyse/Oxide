struct GalleryEffectSection: Identifiable, Sendable {
    let id: String
    let title: String
    let presets: [GalleryEffectPreset]

    func contains(presetID: GalleryEffectPreset.ID?) -> Bool {
        guard let presetID else { return false }
        return presets.contains { $0.id == presetID }
    }
}

struct GalleryEffectCatalog: Sendable {
    let none: GalleryEffectPreset
    let sections: [GalleryEffectSection]

    init(presets: [GalleryEffectPreset]) {
        none = presets.first(where: \.isNone) ?? GalleryEffectPreset.all[0]

        let effectPresets = presets.filter { !$0.isNone }
        var assignedPresetIDs = Set<GalleryEffectPreset.ID>()
        var result = GalleryEffectSectionDefinition.allCases.compactMap { definition -> GalleryEffectSection? in
            let matchingPresets = effectPresets.filter { definition.kinds.contains($0.kind) }
            guard !matchingPresets.isEmpty else { return nil }
            assignedPresetIDs.formUnion(matchingPresets.map(\.id))
            return GalleryEffectSection(
                id: definition.rawValue,
                title: definition.title,
                presets: matchingPresets
            )
        }

        let uncategorized = effectPresets.filter { !assignedPresetIDs.contains($0.id) }
        if !uncategorized.isEmpty {
            result.append(GalleryEffectSection(id: "other", title: "Other", presets: uncategorized))
        }
        sections = result
    }

    func section(containing presetID: GalleryEffectPreset.ID?) -> GalleryEffectSection? {
        sections.first { $0.contains(presetID: presetID) }
    }
}

private enum GalleryEffectSectionDefinition: String, CaseIterable {
    case film
    case light
    case lens
    case creative

    var title: String { rawValue.capitalized }

    var kinds: [GalleryEffectKind] {
        switch self {
        case .film:
            [.filmGrain, .halation, .dustAndScratches, .vhs]
        case .light:
            [.lightLeak, .bloom, .sparkle]
        case .lens:
            [.chromaticAberration, .lensWarp, .motionBlur, .zoomBlur, .tiltShift, .edgeBlur, .vignette]
        case .creative:
            [.kaleidoscope, .pixelSort]
        }
    }
}
