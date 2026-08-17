// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import CoreImage
import Foundation
import os

final class LUTPreparationService: @unchecked Sendable {
    typealias LookupImageLoader = @Sendable (LUTFilterPreset) -> CIImage?
    typealias CubeDataBuilder = @Sendable (CIImage) -> Data?

    static let shared = LUTPreparationService()

    private let cache: LUTCubeCache
    private let lookupImageLoader: LookupImageLoader
    private let cubeDataBuilder: CubeDataBuilder
    private let inFlight = OSAllocatedUnfairLock(
        initialState: [String: Task<Data?, Never>]()
    )

    init(
        cache: LUTCubeCache = LUTCubeCache(),
        context: CIContext? = nil,
        lookupImageLoader: LookupImageLoader? = nil,
        cubeDataBuilder: CubeDataBuilder? = nil
    ) {
        let context = SendableCIContext(context ?? Self.makeContext())
        self.cache = cache
        self.lookupImageLoader = lookupImageLoader ?? Self.loadLookupImage
        self.cubeDataBuilder = cubeDataBuilder ?? {
            LUTColorCubeFactory.makeCubeData(from: $0, context: context.value)
        }
    }

    func cachedCubeData(for preset: LUTFilterPreset) -> Data? {
        cache.data(forKey: preset.id)
    }

    func cubeData(for preset: LUTFilterPreset) async -> Data? {
        if let cachedData = cache.data(forKey: preset.id) {
            return cachedData
        }

        let lookupImageLoader = lookupImageLoader
        let cubeDataBuilder = cubeDataBuilder
        let (request, ownsRequest) = inFlight.withLock { requests in
            if let existingRequest = requests[preset.id] {
                return (existingRequest, false)
            }

            let request = Task.detached(priority: Task.currentPriority) {
                lookupImageLoader(preset).flatMap(cubeDataBuilder)
            }
            requests[preset.id] = request
            return (request, true)
        }

        let cubeData = await request.value
        if ownsRequest, let cubeData {
            cache.insert(cubeData, forKey: preset.id)
        }

        if ownsRequest {
            inFlight.withLock { requests in
                requests[preset.id] = nil
            }
        }

        return cubeData
    }

    func cubeDataSynchronously(for preset: LUTFilterPreset) -> Data? {
        if let cachedData = cache.data(forKey: preset.id) {
            return cachedData
        }

        let cubeData = lookupImageLoader(preset).flatMap(cubeDataBuilder)
        if let cubeData {
            cache.insert(cubeData, forKey: preset.id)
        }
        return cubeData
    }

    func removeAllCachedData() {
        cache.removeAll()
    }

    private static func loadLookupImage(for preset: LUTFilterPreset) -> CIImage? {
        if
            let resourceName = preset.lutResourceName,
            let url = LUTFilterPreset.bundledResourceURL(for: resourceName)
        {
            return CIImage(
                contentsOf: url,
                options: [
                    .colorSpace: CGColorSpace(name: CGColorSpace.sRGB) as Any
                ]
            )
        }

        return LUTImageFactory.makeLookupImage(for: preset)
    }

    private static func makeContext() -> CIContext {
        CIContext(
            options: [
                .workingColorSpace: CGColorSpace(name: CGColorSpace.sRGB) as Any,
                .outputColorSpace: CGColorSpace(name: CGColorSpace.sRGB) as Any,
                .cacheIntermediates: false
            ]
        )
    }
}
