// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import CoreImage
import Foundation
import Testing
import UIKit
@testable import ImageProcessor

struct LUTPreparationServiceTests {
    @Test func cacheUsesBoundedCubeCost() {
        let cache = LUTCubeCache(maximumCubeCount: 4)

        #expect(cache.maximumCubeCount == 4)
        #expect(cache.totalCostLimit == LUTCubeCache.bytesPerCube * 4)
        #expect(cache.totalCostLimit == 16 * 1_024 * 1_024)
    }

    @Test func cacheClearsOnMemoryWarning() {
        let notificationCenter = NotificationCenter()
        let cache = LUTCubeCache(
            maximumCubeCount: 4,
            notificationCenter: notificationCenter
        )
        cache.insert(Data([1, 2, 3]), forKey: "preset")

        notificationCenter.post(
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )

        #expect(cache.data(forKey: "preset") == nil)
    }

    @Test func preparationCachesSuccessfulCubeData() async {
        let loadCount = LockedCounter()
        let buildCount = LockedCounter()
        let expectedData = Data([1, 2, 3, 4])
        let service = makeService(
            loadCount: loadCount,
            buildCount: buildCount,
            result: expectedData
        )
        let preset = LUTFilterPreset(id: "cached", name: "Cached")

        let firstResult = await service.cubeData(for: preset)
        let secondResult = await service.cubeData(for: preset)

        #expect(firstResult == expectedData)
        #expect(secondResult == expectedData)
        #expect(loadCount.value == 1)
        #expect(buildCount.value == 1)
    }

    @Test func concurrentRequestsShareOnePreparation() async {
        let loadCount = LockedCounter()
        let buildCount = LockedCounter()
        let expectedData = Data(repeating: 7, count: 32)
        let service = makeService(
            loadCount: loadCount,
            buildCount: buildCount,
            result: expectedData,
            buildDelay: 0.05
        )
        let preset = LUTFilterPreset(id: "concurrent", name: "Concurrent")

        let results = await withTaskGroup(of: Data?.self) { group in
            for _ in 0..<12 {
                group.addTask {
                    await service.cubeData(for: preset)
                }
            }

            var values: [Data?] = []
            for await result in group {
                values.append(result)
            }
            return values
        }

        #expect(results.count == 12)
        #expect(results.allSatisfy { $0 == expectedData })
        #expect(loadCount.value == 1)
        #expect(buildCount.value == 1)
    }

    @Test func failedPreparationIsRetried() async {
        let loadCount = LockedCounter()
        let service = LUTPreparationService(
            cache: LUTCubeCache(),
            lookupImageLoader: { _ in
                loadCount.increment()
                return nil
            },
            cubeDataBuilder: { _ in
                Issue.record("Builder must not run without a lookup image")
                return Data()
            }
        )
        let preset = LUTFilterPreset(id: "missing", name: "Missing")

        #expect(await service.cubeData(for: preset) == nil)
        #expect(await service.cubeData(for: preset) == nil)
        #expect(loadCount.value == 2)
    }

    private func makeService(
        loadCount: LockedCounter,
        buildCount: LockedCounter,
        result: Data,
        buildDelay: TimeInterval = 0
    ) -> LUTPreparationService {
        LUTPreparationService(
            cache: LUTCubeCache(),
            lookupImageLoader: { _ in
                loadCount.increment()
                return CIImage(color: .white)
            },
            cubeDataBuilder: { _ in
                buildCount.increment()
                if buildDelay > 0 {
                    Thread.sleep(forTimeInterval: buildDelay)
                }
                return result
            }
        )
    }
}

private final class LockedCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var count = 0

    var value: Int {
        lock.withLock { count }
    }

    func increment() {
        lock.withLock {
            count += 1
        }
    }
}
