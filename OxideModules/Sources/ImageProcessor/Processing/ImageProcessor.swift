// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Foundation
import CoreImage
import Metal
#if canImport(OxideEffects)
import OxideEffects
#endif
import UIKit

public final class ImageProcessor: @unchecked Sendable {
    private let filterQueue = DispatchQueue(
        label: "com.softfusion.filterworker",
        qos: .userInitiated
    )
    private let context: CIContext
    private let lutPreparationService: LUTPreparationService

    public convenience init() {
        self.init(lutPreparationService: .shared)
    }

    init(lutPreparationService: LUTPreparationService) {
        self.lutPreparationService = lutPreparationService
        if let device = MTLCreateSystemDefaultDevice() {
            self.context = CIContext(
                mtlDevice: device,
                options: [
                    .workingColorSpace: CGColorSpace(name: CGColorSpace.sRGB) as Any,
                    .outputColorSpace: CGColorSpace(name: CGColorSpace.sRGB) as Any,
                    .cacheIntermediates: false
                ]
            )
        } else {
            self.context = CIContext(
                options: [
                    .workingColorSpace: CGColorSpace(name: CGColorSpace.sRGB) as Any,
                    .outputColorSpace: CGColorSpace(name: CGColorSpace.sRGB) as Any,
                    .cacheIntermediates: false
                ]
            )
        }
    }

    public func outputImage(
        for inputImage: CIImage,
        presetID: String?,
        intensity: Double? = nil,
        adjustments: ImageAdjustments = .neutral,
        effects: ImageEffects = .neutral
    ) -> CIImage? {
        guard
            let preset = LUTFilterPreset.all.first(where: { $0.id == (presetID ?? LUTFilterPreset.original.id) }),
            preset.id != LUTFilterPreset.original.id
        else {
            let adjustedImage = ImageAdjustmentFilter.apply(
                to: inputImage,
                adjustments: adjustments
            )
            return applyEffects(effects, to: adjustedImage)
        }

        guard
            let cubeData = lutPreparationService.cubeDataSynchronously(for: preset)
        else {
            let adjustedImage = ImageAdjustmentFilter.apply(
                to: inputImage,
                adjustments: adjustments
            )
            return applyEffects(effects, to: adjustedImage)
        }

        guard let filteredImage = LUTImageFilter.apply(
            to: inputImage,
            preset: preset,
            cubeData: cubeData,
            intensity: intensity
        ) else {
            return nil
        }

        let adjustedImage = ImageAdjustmentFilter.apply(
            to: filteredImage,
            adjustments: adjustments
        )
        return applyEffects(effects, to: adjustedImage)
    }

    public func renderUIImage(
        from imageURL: URL,
        presetID: String?,
        intensity: Double? = nil,
        rotationDegrees: Int = 0,
        crop: ImageEditCrop? = nil,
        cropRect: CGRect? = nil,
        adjustments: ImageAdjustments = .neutral,
        effects: ImageEffects = .neutral,
        maxPixelSize: CGFloat? = nil
    ) async -> UIImage? {
        let renderTask = Task.detached(priority: .userInitiated) { [self] () -> UIImage? in
            guard !Task.isCancelled else { return nil }
            let cropRect = crop?.coreImageNormalizedRect ?? cropRect
            guard
                let sourceImage = CIImage(contentsOf: imageURL),
                let croppedImage = croppedImage(sourceImage, cropRect: cropRect),
                let inputImage = scaledImage(croppedImage, maxPixelSize: maxPixelSize)
            else {
                return nil
            }

            let processedImage: CIImage
            if
                let preset = preset(for: presetID),
                preset.id != LUTFilterPreset.original.id
            {
                guard
                    let cubeData = await lutPreparationService.cubeData(for: preset),
                    let filteredImage = LUTImageFilter.apply(
                        to: inputImage,
                        preset: preset,
                        cubeData: cubeData,
                        intensity: intensity
                    )
                else {
                    return nil
                }
                processedImage = filteredImage
            } else {
                processedImage = inputImage
            }

            guard !Task.isCancelled else { return nil }
            let adjustedImage = ImageAdjustmentFilter.apply(
                to: processedImage,
                adjustments: adjustments
            )
            let effectedImage = applyEffects(effects, to: adjustedImage)
            let rotatedImage = effectedImage.transformed(
                by: rotationTransform(
                    degrees: rotationDegrees,
                    extent: adjustedImage.extent
                )
            )
            guard !Task.isCancelled else { return nil }
            guard let cgImage = createCGImage(rotatedImage) else {
                return nil
            }

            guard !Task.isCancelled else { return nil }
            return UIImage(cgImage: cgImage)
        }

        return await withTaskCancellationHandler {
            await renderTask.value
        } onCancel: {
            renderTask.cancel()
        }
    }

    public func prepareLUT(presetID: String) async {
        guard
            let preset = LUTFilterPreset.all.first(where: { $0.id == presetID }),
            preset.id != LUTFilterPreset.original.id
        else {
            return
        }

        guard !Task.isCancelled else { return }
        _ = await lutPreparationService.cubeData(for: preset)
    }

    public func sourceSize(for imageURL: URL) -> CGSize? {
        CIImage(contentsOf: imageURL)?.extent.size
    }

    private func croppedImage(_ image: CIImage, cropRect: CGRect?) -> CIImage? {
        guard let cropRect else {
            return image
        }

        let clampedCrop = cropRect.intersection(CGRect(x: 0, y: 0, width: 1, height: 1))
        guard clampedCrop.width > 0, clampedCrop.height > 0 else {
            return image
        }

        let extent = image.extent
        let rect = CGRect(
            x: extent.minX + extent.width * clampedCrop.minX,
            y: extent.minY + extent.height * clampedCrop.minY,
            width: extent.width * clampedCrop.width,
            height: extent.height * clampedCrop.height
        )

        return image
            .cropped(to: rect)
            .transformed(by: CGAffineTransform(translationX: -rect.minX, y: -rect.minY))
    }

    private func scaledImage(_ image: CIImage, maxPixelSize: CGFloat?) -> CIImage? {
        guard let maxPixelSize, maxPixelSize > 0 else {
            return image
        }

        let longestSide = max(image.extent.width, image.extent.height)
        guard longestSide > maxPixelSize else {
            return image
        }

        let scale = maxPixelSize / longestSide
        return image
            .transformed(by: CGAffineTransform(scaleX: scale, y: scale))
            .transformed(by: CGAffineTransform(translationX: -image.extent.minX * scale, y: -image.extent.minY * scale))
    }

    private func rotationTransform(degrees: Int, extent: CGRect) -> CGAffineTransform {
        let radians = CGFloat(degrees) * .pi / 180
        let center = CGPoint(x: extent.midX, y: extent.midY)
        return CGAffineTransform(translationX: center.x, y: center.y)
            .rotated(by: radians)
            .translatedBy(x: -center.x, y: -center.y)
    }

    private func preset(for presetID: String?) -> LUTFilterPreset? {
        LUTFilterPreset.all.first {
            $0.id == (presetID ?? LUTFilterPreset.original.id)
        }
    }

    private func applyEffects(_ effects: ImageEffects, to image: CIImage) -> CIImage {
#if canImport(OxideEffects)
        EffectPipelineRenderer().apply(
            EffectRecipe(
                filmGrain: FilmGrainSettings(
                    amount: effects.filmGrain.amount,
                    size: effects.filmGrain.size,
                    seed: effects.filmGrain.seed
                ),
                lightLeak: LightLeakSettings(
                    amount: effects.lightLeak.amount,
                    position: effects.lightLeak.position,
                    warmth: effects.lightLeak.warmth,
                    seed: effects.lightLeak.seed,
                    spatialMask: effects.lightLeak.spatialMask.effectMask
                ),
                chromaticAberration: ChromaticAberrationSettings(
                    amount: effects.chromaticAberration.amount,
                    direction: effects.chromaticAberration.direction,
                    falloff: effects.chromaticAberration.falloff,
                    spatialMask: effects.chromaticAberration.spatialMask.effectMask
                ),
                halation: HalationSettings(
                    amount: effects.halation.amount,
                    radius: effects.halation.radius,
                    threshold: effects.halation.threshold,
                    spatialMask: effects.halation.spatialMask.effectMask
                ),
                dustAndScratches: DustAndScratchesSettings(
                    amount: effects.dustAndScratches.amount,
                    dustAmount: effects.dustAndScratches.dustAmount,
                    scratchAmount: effects.dustAndScratches.scratchAmount,
                    particleSize: effects.dustAndScratches.particleSize,
                    seed: effects.dustAndScratches.seed
                ),
                bloom: BloomSettings(
                    amount: effects.bloom.amount,
                    radius: effects.bloom.radius,
                    threshold: effects.bloom.threshold,
                    warmth: effects.bloom.warmth,
                    spatialMask: effects.bloom.spatialMask.effectMask
                ),
                vhs: VHSSettings(
                    amount: effects.vhs.amount,
                    distortion: effects.vhs.distortion,
                    scanlines: effects.vhs.scanlines,
                    colorBleed: effects.vhs.colorBleed,
                    seed: effects.vhs.seed
                ),
                lensWarp: LensWarpSettings(
                    amount: effects.lensWarp.amount,
                    scale: effects.lensWarp.scale,
                    spatialMask: effects.lensWarp.spatialMask.effectMask
                ),
                motionBlur: MotionBlurSettings(
                    amount: effects.motionBlur.amount,
                    distance: effects.motionBlur.distance,
                    angle: effects.motionBlur.angle
                ),
                zoomBlur: ZoomBlurSettings(
                    amount: effects.zoomBlur.amount,
                    strength: effects.zoomBlur.strength,
                    spatialMask: effects.zoomBlur.spatialMask.effectMask
                )
            ),
            to: image
        )
#else
        image
#endif
    }

    private func createCGImage(_ image: CIImage) -> CGImage? {
        if let image = context.createCGImage(image, from: image.extent) {
            return image
        }

        let softwareContext = CIContext(
            options: [
                .useSoftwareRenderer: true,
                .workingColorSpace: CGColorSpace(name: CGColorSpace.sRGB) as Any,
                .outputColorSpace: CGColorSpace(name: CGColorSpace.sRGB) as Any,
                .cacheIntermediates: false
            ]
        )
        return softwareContext.createCGImage(image, from: image.extent)
    }

    public func process(
        original: UIImage,
        filter: CIFilter,
        intensity: NSNumber
    ) async -> UIImage? {
        guard let localFilter = filter.copy() as? CIFilter else {
            return nil
        }

        localFilter.setValue(intensity, forKey: "inputIntensity")
        return await withCheckedContinuation { continuation in
            filterQueue.async { [context, localFilter] in
                guard let sourceImage = CIImage(image: original) else {
                    continuation.resume(returning: nil)
                    return
                }

                if localFilter.inputKeys.contains(kCIInputImageKey) {
                    localFilter.setValue(sourceImage, forKey: kCIInputImageKey)
                }

                guard
                    let outputImage = localFilter.outputImage,
                    let cgImage = context.createCGImage(
                        outputImage,
                        from: outputImage.extent
                    )
                else {
                    continuation.resume(returning: nil)
                    return
                }

                let result = UIImage(
                    cgImage: cgImage,
                    scale: original.scale,
                    orientation: original.imageOrientation
                )
                continuation.resume(returning: result)
            }
        }
    }
}

#if canImport(OxideEffects)
private extension ImageSpatialEffectMask {
    var effectMask: SpatialEffectMask {
        SpatialEffectMask(
            mode: mode == .spot ? .spot : .fullFrame,
            centerX: centerX,
            centerY: centerY,
            radius: radius,
            feather: feather
        )
    }
}
#endif

extension CIFilter: @unchecked @retroactive Sendable { }
