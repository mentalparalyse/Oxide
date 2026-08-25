// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import AVFoundation
import ImageProcessor
import SwiftUI
import UIComponents

struct GalleryCaptureView: View {
    @ObservedObject var presenter: GalleryPresenter
    @StateObject private var cameraController = CameraSessionController()
    @State private var isTorchEnabled = false
    @State private var isShutterAnimating = false
    @State private var isCaptureFlashVisible = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                cameraSurface

                if isCaptureFlashVisible {
                    Color.white
                        .ignoresSafeArea()
                        .transition(.opacity)
                }

                VStack {
                    HStack {
                        CircularIconButton(systemName: "xmark", accessibilityLabel: "Close camera", size: 40, action: presenter.closeCapture)
                        Spacer()
                        CircularIconButton(
                            systemName: isTorchEnabled ? "bolt.fill" : "bolt.slash",
                            accessibilityLabel: isTorchEnabled ? "Turn torch off" : "Turn torch on",
                            size: 40,
                            action: toggleTorch
                        )
                        .disabled(
                            !cameraController.isTorchAvailable ||
                            cameraController.isSwitchingCamera
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                    Spacer()
                }
            }

            HStack(spacing: 44) {
                LastPhotoButton(photo: presenter.lastPhoto, action: presenter.closeCapture)
                    .frame(width: 56, height: 56)

                Button {
                    animateShutter()
                    cameraController.capturePhoto(flashMode: .off) { url in
                        Task { await presenter.startEditingCapturedPhoto(uri: url) }
                    }
                } label: {
                    Circle()
                        .stroke(AppColours.appForegroundColor, lineWidth: 4)
                        .frame(width: 72, height: 72)
                        .overlay {
                            Circle()
                                .fill(AppColours.appForegroundColor)
                                .frame(width: 56, height: 56)
                        }
                }
                .scaleEffect(isShutterAnimating ? 0.86 : 1)
                .disabled(
                    cameraController.authorizationState != .authorized ||
                    !cameraController.isConfigured ||
                    cameraController.isSwitchingCamera
                )
                .buttonStyle(.plain)
                .accessibilityLabel("Take photo")

                CircularIconButton(
                    systemName: "arrow.triangle.2.circlepath.camera",
                    accessibilityLabel: "Switch camera",
                    size: 40,
                    action: switchCamera
                )
                    .frame(width: 56, height: 56)
                    .disabled(
                        !cameraController.isCameraSwitchAvailable ||
                        cameraController.isSwitchingCamera
                    )
            }
            .padding(.vertical, 28)
            .background(Color.black)
        }
        .onAppear {
            cameraController.requestAccessAndConfigure()
        }
        .onDisappear {
            isTorchEnabled = false
            cameraController.stopRunning()
        }
    }

    @ViewBuilder
    private var cameraSurface: some View {
        switch cameraController.authorizationState {
        case .authorized:
            if cameraController.isConfigured {
                CameraPreview(session: cameraController.session)
                    .ignoresSafeArea()
            } else {
                cameraUnavailableView(message: cameraController.errorMessage ?? "Preparing camera")
            }
        case .notDetermined:
            cameraUnavailableView(message: "Camera permission required")
        case .denied, .restricted:
            cameraUnavailableView(message: "Camera access is disabled")
        }
    }

    private func cameraUnavailableView(message: String) -> some View {
        AppColours.appSurfaceColor
            .overlay {
                VStack(spacing: 12) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 56))
                        .foregroundStyle(AppColours.appMutedForegroundColor)
                    Text(message)
                        .font(.system(size: 16))
                        .foregroundStyle(AppColours.appMutedForegroundColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
            }
    }

    private func toggleTorch() {
        isTorchEnabled.toggle()
        cameraController.setTorchEnabled(isTorchEnabled)
    }

    private func switchCamera() {
        if isTorchEnabled {
            isTorchEnabled = false
            cameraController.setTorchEnabled(false)
        }
        cameraController.switchCamera()
    }

    private func animateShutter() {
        withAnimation(.spring(response: 0.18, dampingFraction: 0.6)) {
            isShutterAnimating = true
            isCaptureFlashVisible = true
        }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 90_000_000)
            withAnimation(.easeOut(duration: 0.16)) {
                isShutterAnimating = false
                isCaptureFlashVisible = false
            }
        }
    }
}
