// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.


/// A custom Core Image filter that applies a color lookup table (LUT) transformation to the input image.
///
/// `LookupFilter` is a subclass of `CIFilter` which accepts an input image, an optional color lookup table image,
/// an optional intensity, and a filter name. The filter can be used to apply complex color grading or mapping
/// operations by using a LUT texture, typically for stylistic color effects or film emulation.
///
/// - Note: This class does not expose its properties as standard `@objc dynamic` CIFilter properties,
///         so it should be used directly with its initializer.
///
/// - Parameters:
///   - inputImage: The input `CIImage` to which the lookup table will be applied.
///   - inputColorLookupTable: An optional `CIImage` representing the color lookup table (LUT).
///   - inputIntensity: An optional `NSNumber` specifying the intensity of the LUT effect (where supported).
///
/// - Important:
///   - This filter does not perform any image processing unless further implementation is provided.
///   - For use in production, override the `outputImage` property and implement the LUT application logic.
///
/// - Author: Lex Sava
/// - Since: 21.09.2025
import CoreImage
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

public final class LookupFilter: CIFilter {
    @objc dynamic public var inputImage: CIImage?
    @objc dynamic public var inputColorLookupTable: CIImage?
    @objc dynamic public var inputIntensity: NSNumber = 1.0
    
    private static let kernel: CIKernel = {
        guard
            let url = Bundle.main.url(forResource: "LookupFilter", withExtension: "cikernel"),
            let code = try? String(contentsOf: url, encoding: .utf8),
            let kernel = CIKernel.makeKernels(source: code)?.first
        else {
            fatalError("❌ Failed to load kernel")
        }
        return kernel
    }()


    public override var inputKeys: [String] {
        [
            kCIInputImageKey,
            "inputColorLookupTable",
            "inputIntensity"
        ]
    }
    

    public override var outputImage: CIImage? {
        guard let inputImage = inputImage else {
            return nil
        }
        
        let lutExtent = inputColorLookupTable?.extent ?? .zero

        return Self.kernel.apply(
            extent: inputImage.extent,
            roiCallback: { index, rect in
                index == 0 ? rect : lutExtent
            },
            arguments: [
                inputImage,
                inputColorLookupTable as Any,
                inputIntensity
            ]
        )
    }
}

extension LookupFilter: @unchecked Sendable {}
