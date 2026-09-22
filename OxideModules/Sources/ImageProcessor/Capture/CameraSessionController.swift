// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

@preconcurrency import AVFoundation
import Foundation
import CoreImage
import ImageIO
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
    @Published public private(set) var isLowLightBoostAvailable = false
    @Published public private(set) var isLowLightBoostEnabled = false

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
    private var captureAspectRatio: CameraAspectRatio = .full

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

    public func focus(at devicePoint: CGPoint) {
        let device = videoDevice
        sessionQueue.async { [weak self] in
            guard let device else { return }
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                if device.isFocusPointOfInterestSupported {
                    device.focusPointOfInterest = devicePoint
                    device.focusMode = device.isFocusModeSupported(.autoFocus) ? .autoFocus : .continuousAutoFocus
                }
                if device.isExposurePointOfInterestSupported {
                    device.exposurePointOfInterest = devicePoint
                    device.exposureMode = device.isExposureModeSupported(.autoExpose) ? .autoExpose : .continuousAutoExposure
                }
            } catch {
                Task { @MainActor in self?.errorMessage = "Focus unavailable" }
            }
        }
    }

    public func setExposureBias(_ bias: Float) {
        let device = videoDevice
        sessionQueue.async { [weak self] in
            guard let device else { return }
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                let value = min(max(bias, device.minExposureTargetBias), device.maxExposureTargetBias)
                device.setExposureTargetBias(value)
            } catch {
                Task { @MainActor in self?.errorMessage = "Brightness unavailable" }
            }
        }
    }

    public func setLowLightBoostEnabled(_ isEnabled: Bool) {
        let device = videoDevice
        sessionQueue.async { [weak self] in
            guard let device, device.isLowLightBoostSupported else { return }
            do {
                try device.lockForConfiguration()
                device.automaticallyEnablesLowLightBoostWhenAvailable = isEnabled
                device.unlockForConfiguration()
                Task { @MainActor in self?.isLowLightBoostEnabled = isEnabled }
            } catch {
                Task { @MainActor in self?.errorMessage = "Night mode unavailable" }
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
                    self.updateLowLightState(for: targetDevice)
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
        aspectRatio: CameraAspectRatio = .full,
        completion: @escaping @MainActor (URL) -> Void
    ) {
        captureCompletion = completion
        captureAspectRatio = aspectRatio
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
                self.updateLowLightState(for: device)
                self.isCameraSwitchAvailable = self.hasCamera(
                    at: CameraPositionToggle.opposite(of: device.position)
                )
            }
        }
    }


    private func updateLowLightState(for device: AVCaptureDevice) {
        isLowLightBoostAvailable = device.isLowLightBoostSupported
        isLowLightBoostEnabled = device.isLowLightBoostSupported && device.automaticallyEnablesLowLightBoostWhenAvailable
    }

    nonisolated private static func processedCaptureData(
        _ data: Data,
        aspectRatio: CameraAspectRatio
    ) -> Data? {
        guard var image = CIImage(data: data, options: [.applyOrientationProperty: true]) else { return nil }

        if let ratio = aspectRatio.ratio {
            let extent = image.extent
            let desiredRatio = extent.width < extent.height ? 1 / ratio : ratio
            let currentRatio = extent.width / extent.height
            let size: CGSize
            if currentRatio > desiredRatio {
                size = CGSize(width: extent.height * desiredRatio, height: extent.height)
            } else {
                size = CGSize(width: extent.width, height: extent.width / desiredRatio)
            }
            image = image.cropped(to: CGRect(
                x: extent.midX - size.width / 2,
                y: extent.midY - size.height / 2,
                width: size.width,
                height: size.height
            ))
        }

        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else { return nil }
        return CIContext(options: [.cacheIntermediates: false]).jpegRepresentation(
            of: image,
            colorSpace: colorSpace,
            options: [kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption: 0.95]
        )
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
        guard error == nil, let sourceData = photo.fileDataRepresentation() else {
            Task { @MainActor in
                self.errorMessage = "Capture failed"
            }
            return
        }

        Task {
            do {
                let aspectRatio = await MainActor.run { self.captureAspectRatio }
                let data = Self.processedCaptureData(
                    sourceData,
                    aspectRatio: aspectRatio
                ) ?? sourceData
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
