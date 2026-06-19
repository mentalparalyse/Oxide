// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import CoreGraphics
import CoreImage
import Foundation

enum LUTColorCubeFactory {
    static let dimension = 64
    
    static func makeCubeData(from lookupImage: CIImage, context: CIContext) -> Data? {
        let extent = lookupImage.extent.integral
        guard
            extent.width >= CGFloat(dimension * 8),
            extent.height >= CGFloat(dimension * 8),
            let cgImage = context.createCGImage(lookupImage, from: extent)
        else {
            return nil
        }
        
        let width = Int(extent.width)
        let height = Int(extent.height)
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        var pixels = [UInt8](repeating: 0, count: height * bytesPerRow)
        
        guard
            let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
            let bitmapContext = CGContext(
                data: &pixels,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: bytesPerRow,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )
        else {
            return nil
        }
        
        bitmapContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var cube = [Float]()
        cube.reserveCapacity(dimension * dimension * dimension * bytesPerPixel)
        
        for blue in 0..<dimension {
            let tileY = blue / 8
            let tileX = blue - tileY * 8
            
            for green in 0..<dimension {
                for red in 0..<dimension {
                    let x = tileX * dimension + red
                    let y = (7 - tileY) * dimension + green
                    let offset = y * bytesPerRow + x * bytesPerPixel
                    
                    cube.append(Float(pixels[offset]) / 255)
                    cube.append(Float(pixels[offset + 1]) / 255)
                    cube.append(Float(pixels[offset + 2]) / 255)
                    cube.append(1)
                }
            }
        }
        
        return cube.withUnsafeBufferPointer { buffer in
            Data(buffer: buffer)
        }
    }
}
