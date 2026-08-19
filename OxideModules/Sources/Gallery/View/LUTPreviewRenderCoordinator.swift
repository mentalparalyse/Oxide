import Foundation
import ImageProcessor
import SwiftUI
import UIKit

struct LUTPreviewRenderRequest: Equatable, Sendable {
    let imageURL: URL?
    let presetID: String?
    let intensity: Double
    let rotationDegrees: Int
    let crop: ImageEditCrop?
    let adjustments: ImageAdjustments
    let effects: ImageEffects
    let maxPixelSize: CGFloat?
}

@MainActor
final class LUTPreviewRenderCoordinator: ObservableObject {
    typealias Renderer = @Sendable (LUTPreviewRenderRequest) async -> UIImage?

    @Published private(set) var image: UIImage?

    private static let imageProcessor = ImageProcessor()
    private let renderer: Renderer
    private var pendingRequest: LUTPreviewRenderRequest?
    private var activeRequest: LUTPreviewRenderRequest?
    private var renderTask: Task<Void, Never>?

    init(renderer: @escaping Renderer = LUTPreviewRenderCoordinator.render) {
        self.renderer = renderer
    }

    func submit(_ request: LUTPreviewRenderRequest) {
        guard request != pendingRequest else { return }
        guard request != activeRequest || pendingRequest != nil else { return }

        pendingRequest = request
        guard renderTask == nil else { return }
        renderTask = Task { [weak self] in
            await self?.renderPendingRequests()
        }
    }

    private func renderPendingRequests() async {
        while !Task.isCancelled, let request = pendingRequest {
            pendingRequest = nil
            activeRequest = request

            guard request.imageURL != nil else {
                image = nil
                continue
            }

            let renderedImage = await renderer(request)

            if let renderedImage {
                image = renderedImage
            }
        }

        activeRequest = nil
        renderTask = nil
    }

    private static func render(_ request: LUTPreviewRenderRequest) async -> UIImage? {
        guard let imageURL = request.imageURL else { return nil }
        return await imageProcessor.renderUIImage(
            from: imageURL,
            presetID: request.presetID,
            intensity: request.intensity,
            rotationDegrees: request.rotationDegrees,
            crop: request.crop,
            adjustments: request.adjustments,
            effects: request.effects,
            maxPixelSize: request.maxPixelSize
        )
    }
}
