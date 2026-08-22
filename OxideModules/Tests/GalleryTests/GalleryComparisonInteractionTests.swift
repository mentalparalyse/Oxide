// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Testing
@testable import Gallery

struct GalleryComparisonInteractionTests {
    @Test func controlsHideOnlyWhileComparisonPressIsActive() {
        var state = GalleryComparisonVisibilityState()

        #expect(!state.areControlsHidden)
        state.beginPress()
        #expect(state.areControlsHidden)
        state.endPress()
        #expect(!state.areControlsHidden)
    }

    @Test func explicitAccessibilityVisibilityPersistsAfterPressEnds() {
        var state = GalleryComparisonVisibilityState()

        state.toggleAccessibilityVisibility()
        state.beginPress()
        state.endPress()

        #expect(state.areControlsHidden)
        state.toggleAccessibilityVisibility()
        #expect(!state.areControlsHidden)
    }

    @Test func disablingInteractionCancelsOnlyPressVisibility() {
        var state = GalleryComparisonVisibilityState()
        state.toggleAccessibilityVisibility()
        state.beginPress()

        state.cancelPressIfDisabled()

        #expect(!state.isPressActive)
        #expect(state.areControlsHidden)
    }

    @Test func cropAndSpatialPositioningOwnTheirGestures() {
        #expect(!GalleryComparisonInteraction.isEligible(activeTool: .crop, isPositioningSpatialEffect: false))
        #expect(!GalleryComparisonInteraction.isEligible(activeTool: .effects, isPositioningSpatialEffect: true))
        #expect(GalleryComparisonInteraction.isEligible(activeTool: .filters, isPositioningSpatialEffect: false))
        #expect(GalleryComparisonInteraction.isEligible(activeTool: .effects, isPositioningSpatialEffect: false))
    }

    @Test func comparisonThresholdIsResponsive() {
        #expect(GalleryComparisonInteraction.minimumPressDuration == 0.2)
    }
}
