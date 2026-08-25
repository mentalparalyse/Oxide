import CoreGraphics
import Testing
@testable import UIComponents

struct ZoomViewportStateTests {
    @Test func scaleClampsToSupportedRange() {
        var viewport = ZoomViewportState()

        viewport.applyScale(20)
        #expect(viewport.scale == ZoomViewportState.maximumScale)

        viewport.applyScale(-2)
        #expect(viewport.scale == ZoomViewportState.minimumScale)
    }

    @Test func minimumScaleClearsPanOffset() {
        var viewport = ZoomViewportState()
        viewport.applyScale(2)
        viewport.applyOffset(
            CGSize(width: 50, height: 50),
            imageSize: CGSize(width: 200, height: 200),
            containerSize: CGSize(width: 100, height: 100)
        )

        viewport.applyScale(1)

        #expect(viewport.offset == .zero)
    }

    @Test func panIsBoundedByScaledImageEdges() {
        var viewport = ZoomViewportState()
        viewport.applyScale(2)

        viewport.applyOffset(
            CGSize(width: 500, height: -500),
            imageSize: CGSize(width: 200, height: 100),
            containerSize: CGSize(width: 200, height: 200)
        )

        #expect(viewport.offset == CGSize(width: 100, height: 0))
    }

    @Test func resetRestoresInitialState() {
        var viewport = ZoomViewportState()
        viewport.applyScale(3)
        viewport.applyOffset(
            CGSize(width: 20, height: 20),
            imageSize: CGSize(width: 200, height: 200),
            containerSize: CGSize(width: 100, height: 100)
        )

        viewport.reset()

        #expect(viewport == ZoomViewportState())
    }

    @Test func invalidImageDimensionsCannotProduceNegativePanLimits() {
        let offset = ZoomViewportState.clampedOffset(
            CGSize(width: 20, height: -20),
            scale: 2,
            imageSize: .zero,
            containerSize: CGSize(width: 100, height: 100)
        )

        #expect(offset == .zero)
    }
}
