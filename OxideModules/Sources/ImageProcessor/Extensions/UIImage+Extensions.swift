// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import UIKit.UIImage
import CoreImage

extension UIImage {
    func filterImage(with filter: CIFilter?, context: CIContext) -> UIImage? {
        guard let filter = filter,
              let source = CIImage(image: self) else { return nil }

        if filter.inputKeys.contains(kCIInputImageKey) {
            filter.setValue(source, forKey: kCIInputImageKey)
        }

        guard let ciOutput = filter.outputImage,
              let cgOutput = context.createCGImage(ciOutput, from: ciOutput.extent) else {
            return nil
        }

        return UIImage(cgImage: cgOutput, scale: self.scale, orientation: self.imageOrientation)
    }
}
