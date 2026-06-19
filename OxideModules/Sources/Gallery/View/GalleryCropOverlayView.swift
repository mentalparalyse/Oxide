// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import ImageProcessor
import SwiftUI

struct CropOverlayView: View {
    let crop: ImageEditCrop?
    let zoomScale: CGFloat
    let onResize: (ImageEditCropEdge, ImageEditCrop?, Double, Double) -> Void
    let onResizeEnded: () -> Void
    
    @State private var dragStartCrop: ImageEditCrop?
    private let handleThickness: CGFloat = 36
    private let strokeColor = Color.white.opacity(0.8)
    
    var body: some View {
        GeometryReader { proxy in
            let rect = cropRect(in: proxy.size)
            
            ZStack(alignment: .topLeading) {
                dimmedOutsideCrop(rect: rect)
                
                cropGrid
                    .frame(width: rect.width, height: rect.height)
                    .offset(x: rect.minX, y: rect.minY)
                
                handle(edge: .leading, in: rect, size: proxy.size)
                    .offset(x: rect.minX - handleThickness / 2, y: rect.minY)
                handle(edge: .trailing, in: rect, size: proxy.size)
                    .offset(x: rect.maxX - handleThickness / 2, y: rect.minY)
                handle(edge: .top, in: rect, size: proxy.size)
                    .offset(x: rect.minX, y: rect.minY - handleThickness / 2)
                handle(edge: .bottom, in: rect, size: proxy.size)
                    .offset(x: rect.minX, y: rect.maxY - handleThickness / 2)
            }
        }
    }
    
    private var cropGrid: some View {
        Rectangle()
            .stroke(strokeColor, lineWidth: 2)
            .overlay {
                VStack(spacing: 0) {
                    ForEach(0..<3, id: \.self) { _ in
                        HStack(spacing: 0) {
                            ForEach(0..<3, id: \.self) { _ in
                                Rectangle()
                                    .stroke(Color.white.opacity(0.22), lineWidth: 0.5)
                            }
                        }
                    }
                }
            }
    }
    
    private func dimmedOutsideCrop(rect: CGRect) -> some View {
        Color.black.opacity(0.28)
            .mask {
                Rectangle()
                    .overlay(alignment: .topLeading) {
                        Rectangle()
                            .frame(width: rect.width, height: rect.height)
                            .offset(x: rect.minX, y: rect.minY)
                            .blendMode(.destinationOut)
                    }
            }
            .compositingGroup()
    }
    
    private func handle(edge: ImageEditCropEdge, in rect: CGRect, size: CGSize) -> some View {
        Color.clear
            .frame(width: hitAreaSize(edge: edge, cropRect: rect).width, height: hitAreaSize(edge: edge, cropRect: rect).height)
            .overlay {
                Capsule()
                    .fill(strokeColor)
                    .frame(width: visibleHandleSize(edge: edge).width, height: visibleHandleSize(edge: edge).height)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if dragStartCrop == nil {
                            dragStartCrop = crop
                        }
                        let scaledWidth = size.width * zoomScale
                        let scaledHeight = size.height * zoomScale
                        let horizontalDelta = scaledWidth > 0 ? Double(value.translation.width / scaledWidth) : 0
                        let verticalDelta = scaledHeight > 0 ? Double(value.translation.height / scaledHeight) : 0
                        onResize(edge, dragStartCrop, horizontalDelta, verticalDelta)
                    }
                    .onEnded { _ in
                        dragStartCrop = nil
                        onResizeEnded()
                    }
            )
            .accessibilityLabel(accessibilityLabel(for: edge))
    }
    
    private func hitAreaSize(edge: ImageEditCropEdge, cropRect: CGRect) -> CGSize {
        switch edge {
        case .leading, .trailing:
            return CGSize(width: handleThickness, height: cropRect.height)
        case .top, .bottom:
            return CGSize(width: cropRect.width, height: handleThickness)
        }
    }
    
    private func visibleHandleSize(edge: ImageEditCropEdge) -> CGSize {
        switch edge {
        case .leading, .trailing:
            return CGSize(width: 4, height: 48)
        case .top, .bottom:
            return CGSize(width: 48, height: 4)
        }
    }
    
    private func cropRect(in size: CGSize) -> CGRect {
        let crop = crop ?? ImageEditCrop(x: 0, y: 0, width: 1, height: 1)
        return CGRect(
            x: size.width * crop.x,
            y: size.height * crop.y,
            width: size.width * crop.width,
            height: size.height * crop.height
        )
    }
    
    private func accessibilityLabel(for edge: ImageEditCropEdge) -> String {
        switch edge {
        case .leading:
            return "Move left crop edge"
        case .trailing:
            return "Move right crop edge"
        case .top:
            return "Move top crop edge"
        case .bottom:
            return "Move bottom crop edge"
        }
    }
}
