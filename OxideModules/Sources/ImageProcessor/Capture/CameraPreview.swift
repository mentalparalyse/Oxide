// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

@preconcurrency import AVFoundation
import SwiftUI
import UIKit

public struct CameraPreview: UIViewRepresentable {
    public let session: AVCaptureSession
    public let onFocus: ((CGPoint, CGPoint) -> Void)?

    public init(session: AVCaptureSession, onFocus: ((CGPoint, CGPoint) -> Void)? = nil) {
        self.session = session
        self.onFocus = onFocus
    }

    public func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        view.onFocus = onFocus
        return view
    }

    public func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {
        uiView.videoPreviewLayer.session = session
        uiView.onFocus = onFocus
    }
}

public final class CameraPreviewUIView: UIView {
    var onFocus: ((CGPoint, CGPoint) -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap(_:))))
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap(_:))))
    }

    public override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    public var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    @objc private func didTap(_ recognizer: UITapGestureRecognizer) {
        let viewPoint = recognizer.location(in: self)
        let devicePoint = videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: viewPoint)
        onFocus?(devicePoint, viewPoint)
    }
}
