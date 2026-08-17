@preconcurrency import AVFoundation

public enum CameraPositionToggle {
    public static func opposite(of position: AVCaptureDevice.Position) -> AVCaptureDevice.Position {
        position == .front ? .back : .front
    }
}
