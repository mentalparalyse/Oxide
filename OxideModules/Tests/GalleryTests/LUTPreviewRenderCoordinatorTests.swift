import Foundation
import ImageProcessor
import Testing
import UIKit
@testable import Gallery

@MainActor
struct LUTPreviewRenderCoordinatorTests {
    @Test func rendersCurrentFrameThenCoalescesToLatestPendingValue() async {
        let renderer = PreviewRendererSpy()
        let coordinator = LUTPreviewRenderCoordinator { request in
            await renderer.render(request)
        }
        let first = request(intensity: 0.1)
        let skipped = request(intensity: 0.5)
        let latest = request(intensity: 0.9)

        coordinator.submit(first)
        await renderer.waitForRequestCount(1)
        coordinator.submit(skipped)
        coordinator.submit(latest)
        await renderer.completeNext()
        await renderer.waitForRequestCount(2)

        #expect(await renderer.requests() == [first, latest])
        await renderer.completeNext()
    }

    private func request(intensity: Double) -> LUTPreviewRenderRequest {
        LUTPreviewRenderRequest(
            imageURL: URL(fileURLWithPath: "/tmp/preview.jpg"),
            presetID: nil,
            intensity: intensity,
            rotationDegrees: 0,
            crop: nil,
            adjustments: .neutral,
            effects: .neutral,
            maxPixelSize: 1_600
        )
    }
}

private actor PreviewRendererSpy {
    private var recordedRequests: [LUTPreviewRenderRequest] = []
    private var continuations: [CheckedContinuation<UIImage?, Never>] = []

    func render(_ request: LUTPreviewRenderRequest) async -> UIImage? {
        recordedRequests.append(request)
        return await withCheckedContinuation { continuation in
            continuations.append(continuation)
        }
    }

    func requests() -> [LUTPreviewRenderRequest] {
        recordedRequests
    }

    func completeNext() {
        continuations.removeFirst().resume(returning: UIImage())
    }

    func waitForRequestCount(_ count: Int) async {
        while recordedRequests.count < count {
            await Task.yield()
        }
    }
}
