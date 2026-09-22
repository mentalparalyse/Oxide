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
    private var generation = 0

    init(renderer: @escaping Renderer = LUTPreviewRenderCoordinator.render) {
        self.renderer = renderer
    }

    func submit(_ request: LUTPreviewRenderRequest) {
        guard request != pendingRequest else { return }
        guard request != activeRequest || pendingRequest != nil else { return }

        pendingRequest = request
        guard renderTask == nil else { return }
        let generation = generation
        let renderer = renderer
        renderTask = Task { [weak self, renderer] in
            while !Task.isCancelled {
                guard let request = self?.takePendingRequest(generation: generation) else { return }
                let renderedImage = await renderer(request)
                guard self?.finishRendering(
                    renderedImage,
                    generation: generation
                ) == true else { return }
            }
        }
    }

    func cancel() {
        generation += 1
        pendingRequest = nil
        activeRequest = nil
        renderTask?.cancel()
        renderTask = nil
        image = nil
    }

    private func takePendingRequest(generation: Int) -> LUTPreviewRenderRequest? {
        guard generation == self.generation, let request = pendingRequest else {
            activeRequest = nil
            renderTask = nil
            return nil
        }
        pendingRequest = nil
        activeRequest = request

        guard request.imageURL != nil else {
            image = nil
            return takePendingRequest(generation: generation)
        }
        return request
    }

    private func finishRendering(_ renderedImage: UIImage?, generation: Int) -> Bool {
        guard generation == self.generation, !Task.isCancelled else { return false }
        if let renderedImage { image = renderedImage }
        if pendingRequest == nil {
            activeRequest = nil
            renderTask = nil
            return false
        }
        return true
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
