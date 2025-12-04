// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Foundation
import UIKit
 
public class ImageProcessor {
    private let filterQueue = DispatchQueue(
        label: "com.softfusion.filterworker",
        qos: .userInitiated
    )
    private var currentWorkItem: DispatchWorkItem?
    private let context: CIContext
    
    public init() {
        self.context = CIContext(
            options: [
                .workingColorSpace: CGColorSpace(name: CGColorSpace.sRGB)!,
                .priorityRequestLow: true
            ]
        )
    }
    
    public func process(
        original: UIImage,
        filter: CIFilter,
        intensity: NSNumber,
        completion: @escaping @Sendable (UIImage?) -> Void
    ) {
        currentWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            filter.setValue(intensity, forKey: "inputIntensity")
            
            let result = original.filterImage(with: filter, context: self.context)
            
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        currentWorkItem = workItem
        filterQueue.async(execute: workItem)
    }
    
    public func process(
        original: UIImage,
        filter: CIFilter,
        intensity: NSNumber
    ) async -> UIImage? {
        return nil
//        await Task.detached(priority: .userInitiated) { [weak self] in
//            guard let self else { return nil }
//            let localFilter = filter.copy() as? CIFilter
//            localFilter?.setValue(intensity, forKey: "inputIntensity")
//            
//            return await withCheckedContinuation { continuation in
//                self.filterQueue.async {
//                    let result = original.filterImage(with: localFilter, context: self.context)
//                    continuation.resume(returning: result)
//                }
//            }
//        }.value
    }
    
    
    
    public func apply(
        filter: CIFilter,
        with intensity: Double,
        toOriginal image: UIImage,
        completion: @escaping @Sendable (UIImage?) -> Void
    ) {
        currentWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            filter.setValue(NSNumber(value: intensity), forKey: "inputIntensity")
            let result = image.filterImage(with: filter, context: self.context)
            
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        currentWorkItem = workItem
        filterQueue.async(execute: workItem)
    }
}


public final actor UndoManager<Path> {
    private var paths: [Path] = []
    private var currentIndex: Int = 0
    
    public var canUndo: Bool{
        currentIndex > 0
    }
    
    public var canRedo: Bool{
        currentIndex < paths.count - 1
    }
}

extension UndoManager {
    public func add(_ object: Path) {
        paths.append(object)
        currentIndex = paths.count - 1
        print(paths, currentIndex)
    }
    
    public func redo() -> Path? {
        guard canRedo else { return nil }
        currentIndex += 1
        return paths[currentIndex]
    }
    
    public func undo() -> Path? {
        guard canUndo else { return nil }
        currentIndex -= 1
        return paths[currentIndex]
    }
    public func removeAll(){
//        FileManagerHelper.instance.removeTmp()
        paths.removeAll()
        currentIndex = 0
    }
}


extension CIFilter: @unchecked @retroactive Sendable { }
