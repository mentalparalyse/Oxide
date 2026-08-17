// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

@preconcurrency import AVFoundation
import Foundation
import UIKit

@MainActor
public final class CameraSessionController: NSObject, ObservableObject, @unchecked Sendable {
    @Published public private(set) var authorizationState: CameraAuthorizationState = .notDetermined
    @Published public private(set) var isConfigured = false
    @Published public private(set) var isTorchAvailable = false
    @Published public private(set) var isCameraSwitchAvailable = false
    @Published public private(set) var isSwitchingCamera = false
    @Published public private(set) var currentPosition: AVCaptureDevice.Position
    @Published public private(set) var errorMessage: String?

    public let session = AVCaptureSession()

    private let sessionQueue = DispatchQueue(
        label: "ImageProcessor.CameraSession",
        qos: .userInitiated
    )
    private let photoOutput = AVCapturePhotoOutput()
    nonisolated private let imageFileStore: ImageFileStore
    private let configuration: CameraCaptureConfiguration
    private var videoDevice: AVCaptureDevice?
    private var isConfigurationRequested = false
    private var captureCompletion: (@MainActor (URL) -> Void)?

    public init(
        configuration: CameraCaptureConfiguration = CameraCaptureConfiguration(),
        imageFileStore: ImageFileStore = ImageFileStore()
    ) {
        self.configuration = configuration
        self.imageFileStore = imageFileStore
        self.currentPosition = configuration.position
        super.init()
        authorizationState = currentAuthorizationState()
    }

    public func requestAccessAndConfigure() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            authorizationState = .authorized
            configureIfNeeded()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] isGranted in
                Task { @MainActor in
                    self?.authorizationState = isGranted ? .authorized : .denied
                    if isGranted {
                        self?.configureIfNeeded()
                    }
                }
            }
        case .denied:
            authorizationState = .denied
        case .restricted:
            authorizationState = .restricted
        @unknown default:
            authorizationState = .denied
        }
    }

    public func startRunning() {
        let session = session
        sessionQueue.async {
            guard !session.isRunning, !session.inputs.isEmpty else { return }
            session.startRunning()
        }
    }

    public func stopRunning() {
        let session = session
        let device = videoDevice
        sessionQueue.async {
            if device?.torchMode == .on {
                try? device?.lockForConfiguration()
                device?.torchMode = .off
                device?.unlockForConfiguration()
            }
            guard session.isRunning else { return }
            session.stopRunning()
        }
    }

    public func setTorchEnabled(_ isEnabled: Bool) {
        let device = videoDevice
        sessionQueue.async { [weak self] in
            guard let device, device.hasTorch else { return }
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                device.torchMode = isEnabled ? .on : .off
            } catch {
                Task { @MainActor in self?.errorMessage = "Torch unavailable" }
            }
        }
    }

    public func switchCamera() {
        guard isConfigured, !isSwitchingCamera else { return }
        let targetPosition = CameraPositionToggle.opposite(of: currentPosition)
        guard let targetDevice = AVCaptureDevice.default(
            configuration.deviceType,
            for: .video,
            position: targetPosition
        ) else {
            errorMessage = "Camera unavailable"
            return
        }

        isSwitchingCamera = true
        errorMessage = nil
        let session = session
        let currentDevice = videoDevice
        sessionQueue.async { [weak self] in
            guard
                let currentInput = session.inputs
                    .compactMap({ $0 as? AVCaptureDeviceInput })
                    .first(where: { $0.device.hasMediaType(.video) }),
                let targetInput = try? AVCaptureDeviceInput(device: targetDevice)
            else {
                Task { @MainActor in
                    self?.isSwitchingCamera = false
                    self?.errorMessage = "Unable to switch camera"
                }
                return
            }

            if currentDevice?.torchMode == .on {
                try? currentDevice?.lockForConfiguration()
                currentDevice?.torchMode = .off
                currentDevice?.unlockForConfiguration()
            }

            session.beginConfiguration()
            session.removeInput(currentInput)
            let didSwitch: Bool
            if session.canAddInput(targetInput) {
                session.addInput(targetInput)
                didSwitch = true
            } else {
                if session.canAddInput(currentInput) {
                    session.addInput(currentInput)
                }
                didSwitch = false
            }
            session.commitConfiguration()

            Task { @MainActor in
                guard let self else { return }
                self.isSwitchingCamera = false
                if didSwitch {
                    self.videoDevice = targetDevice
                    self.currentPosition = targetPosition
                    self.isTorchAvailable = targetDevice.hasTorch
                    self.isCameraSwitchAvailable = self.hasCamera(
                        at: CameraPositionToggle.opposite(of: targetPosition)
                    )
                } else {
                    self.errorMessage = "Unable to switch camera"
                }
            }
        }
    }

    public func capturePhoto(
        flashMode: AVCaptureDevice.FlashMode,
        completion: @escaping @MainActor (URL) -> Void
    ) {
        captureCompletion = completion
        let isConfigured = isConfigured
        let photoOutput = photoOutput
        let delegate = self
        sessionQueue.async {
            guard isConfigured else { return }
            let settings = AVCapturePhotoSettings()
            if photoOutput.supportedFlashModes.contains(flashMode) {
                settings.flashMode = flashMode
            }
            photoOutput.capturePhoto(with: settings, delegate: delegate)
        }
    }

    private func configureIfNeeded() {
        guard !isConfigured, !isConfigurationRequested else { return }
        isConfigurationRequested = true

        let session = session
        let photoOutput = photoOutput
        sessionQueue.async { [weak self] in
            guard let self else { return }

            session.beginConfiguration()
            session.sessionPreset = self.configuration.sessionPreset

            guard
                let device = AVCaptureDevice.default(
                    self.configuration.deviceType,
                    for: .video,
                    position: self.configuration.position
                ),
                let input = try? AVCaptureDeviceInput(device: device),
                session.canAddInput(input),
                session.canAddOutput(photoOutput)
            else {
                session.commitConfiguration()
                Task { @MainActor in
                    self.isConfigurationRequested = false
                    self.errorMessage = "Camera unavailable"
                }
                return
            }

            session.addInput(input)
            session.addOutput(photoOutput)
            photoOutput.maxPhotoQualityPrioritization = self.configuration.qualityPrioritization
            session.commitConfiguration()

            if !session.isRunning {
                session.startRunning()
            }

            Task { @MainActor in
                self.videoDevice = device
                self.currentPosition = device.position
                self.isConfigured = true
                self.isTorchAvailable = device.hasTorch
                self.isCameraSwitchAvailable = self.hasCamera(
                    at: CameraPositionToggle.opposite(of: device.position)
                )
            }
        }
    }

    private func hasCamera(at position: AVCaptureDevice.Position) -> Bool {
        AVCaptureDevice.default(
            configuration.deviceType,
            for: .video,
            position: position
        ) != nil
    }

    private func currentAuthorizationState() -> CameraAuthorizationState {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined: .notDetermined
        case .authorized: .authorized
        case .denied: .denied
        case .restricted: .restricted
        @unknown default: .denied
        }
    }
}

extension CameraSessionController: AVCapturePhotoCaptureDelegate {
    nonisolated public func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard error == nil, let data = photo.fileDataRepresentation() else {
            Task { @MainActor in
                self.errorMessage = "Capture failed"
            }
            return
        }

        Task {
            do {
                let url = try await imageFileStore.writeImageData(data, id: UUID().uuidString)
                await MainActor.run {
                    self.captureCompletion?(url)
                    self.captureCompletion = nil
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Capture save failed"
                }
            }
        }
    }
}

extension AVCaptureSession: @retroactive @unchecked Sendable { }
