// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Foundation
import UIKit

final class LUTCubeCache: @unchecked Sendable {
    static let bytesPerCube = 64 * 64 * 64 * 4 * MemoryLayout<Float>.size

    let maximumCubeCount: Int
    let totalCostLimit: Int

    private let cache = NSCache<NSString, NSData>()
    private let notificationCenter: NotificationCenter
    private var memoryWarningObserver: NSObjectProtocol?

    init(
        maximumCubeCount: Int = 4,
        notificationCenter: NotificationCenter = .default
    ) {
        self.maximumCubeCount = max(1, maximumCubeCount)
        self.totalCostLimit = Self.bytesPerCube * max(1, maximumCubeCount)
        self.notificationCenter = notificationCenter

        cache.countLimit = self.maximumCubeCount
        cache.totalCostLimit = totalCostLimit
        memoryWarningObserver = notificationCenter.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            self?.removeAll()
        }
    }

    deinit {
        if let memoryWarningObserver {
            notificationCenter.removeObserver(memoryWarningObserver)
        }
    }

    func data(forKey key: String) -> Data? {
        cache.object(forKey: key as NSString).map(Data.init(referencing:))
    }

    func insert(_ data: Data, forKey key: String) {
        cache.setObject(
            data as NSData,
            forKey: key as NSString,
            cost: data.count
        )
    }

    func removeAll() {
        cache.removeAllObjects()
    }
}
