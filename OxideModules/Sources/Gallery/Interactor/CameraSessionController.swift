// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

@preconcurrency import AVFoundation
import Foundation
import ImageProcessor
import UIKit

@MainActor
final class CameraSessionController: NSObject, ObservableObject, @unchecked Sendable {
    @Published private(set) var authorizationState: CameraAuthorizationState = .notDetermined
    @Published private(set) var isConfigured = false
    @Published private(set) var errorMessage: String?
    
    let session = AVCaptureSession()
    
    private let sessionQueue = DispatchQueue(label: "com.oxide.camera.session", qos: .userInitiated)
    private let photoOutput = AVCapturePhotoOutput()
    private let imagePersistence = ImageProcessPersistence<ImageProcessEmptySnapshot>()
    private var captureCompletion: ((URL) -> Void)?
    
    override init() {
        super.init()
        authorizationState = Self.currentAuthorizationState()
    }
    
    func requestAccessAndConfigure() {
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
    
    func startRunning() {
        let session = session
        let isConfigured = isConfigured
        sessionQueue.async {
            guard isConfigured, !session.isRunning else { return }
            session.startRunning()
        }
    }
    
    func stopRunning() {
        let session = session
        sessionQueue.async {
            guard session.isRunning else { return }
            session.stopRunning()
        }
    }
    
    func capturePhoto(flashMode: AVCaptureDevice.FlashMode, completion: @escaping (URL) -> Void) {
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
        guard !isConfigured else { return }
        
        let session = session
        let photoOutput = photoOutput
        sessionQueue.async { [weak self] in
            guard let self else { return }
            
            session.beginConfiguration()
            session.sessionPreset = .photo
            
            defer {
                session.commitConfiguration()
            }
            
            guard
                let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                let input = try? AVCaptureDeviceInput(device: device),
                session.canAddInput(input),
                session.canAddOutput(photoOutput)
            else {
                Task { @MainActor in
                    self.errorMessage = "Camera unavailable"
                }
                return
            }
            
            session.addInput(input)
            session.addOutput(photoOutput)
            photoOutput.maxPhotoQualityPrioritization = .quality
            
            Task { @MainActor in
                self.isConfigured = true
                self.startRunning()
            }
        }
    }
    
    private static func currentAuthorizationState() -> CameraAuthorizationState {
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
    nonisolated func photoOutput(
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
        
        do {
            let url = try imagePersistence.writeImageData(data, id: UUID().uuidString)
            Task { @MainActor in
                self.captureCompletion?(url)
                self.captureCompletion = nil
            }
        } catch {
            Task { @MainActor in
                self.errorMessage = "Capture save failed"
            }
        }
    }
}

extension AVCaptureSession: @retroactive @unchecked Sendable { }
