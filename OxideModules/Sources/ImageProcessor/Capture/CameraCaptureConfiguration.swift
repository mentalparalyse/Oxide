@preconcurrency import AVFoundation

public struct CameraCaptureConfiguration: @unchecked Sendable {
    public let sessionPreset: AVCaptureSession.Preset
    public let deviceType: AVCaptureDevice.DeviceType
    public let position: AVCaptureDevice.Position
    public let qualityPrioritization: AVCapturePhotoOutput.QualityPrioritization

    public init(
        sessionPreset: AVCaptureSession.Preset = .photo,
        deviceType: AVCaptureDevice.DeviceType = .builtInWideAngleCamera,
        position: AVCaptureDevice.Position = .back,
        qualityPrioritization: AVCapturePhotoOutput.QualityPrioritization = .quality
    ) {
        self.sessionPreset = sessionPreset
        self.deviceType = deviceType
        self.position = position
        self.qualityPrioritization = qualityPrioritization
    }
}
