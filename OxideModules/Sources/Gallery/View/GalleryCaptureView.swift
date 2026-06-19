// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import AVFoundation
import SwiftUI
import UIComponents

struct GalleryCaptureView: View {
    @ObservedObject var presenter: GalleryPresenter
    @StateObject private var cameraController = CameraSessionController()
    @State private var flashMode: FlashMode = .auto
    @State private var isShutterAnimating = false
    @State private var isCaptureFlashVisible = false
    
    private enum FlashMode: CaseIterable {
        case auto
        case on
        case off
        
        var iconName: String {
            self == .off ? "bolt.slash" : "bolt"
        }
        
        var accessibilityLabel: String {
            switch self {
            case .auto: "Flash auto"
            case .on: "Flash on"
            case .off: "Flash off"
            }
        }
        
        var avFlashMode: AVCaptureDevice.FlashMode {
            switch self {
            case .auto: .auto
            case .on: .on
            case .off: .off
            }
        }
    }
    
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
                        CircleIconButton(systemName: "xmark", label: "Close camera", action: presenter.closeCapture)
                        Spacer()
                        CircleIconButton(systemName: flashMode.iconName, label: flashMode.accessibilityLabel, action: cycleFlash)
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
                    cameraController.capturePhoto(flashMode: flashMode.avFlashMode) { url in
                        presenter.startEditingCapturedPhoto(uri: url)
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
                .disabled(cameraController.authorizationState != .authorized || !cameraController.isConfigured)
                .buttonStyle(.plain)
                .accessibilityLabel("Take photo")
                
                Color.clear
                    .frame(width: 56, height: 56)
            }
            .padding(.vertical, 28)
            .background(Color.black)
        }
        .onAppear {
            cameraController.requestAccessAndConfigure()
        }
        .onDisappear {
            cameraController.stopRunning()
        }
    }
    
    @ViewBuilder
    private var cameraSurface: some View {
        switch cameraController.authorizationState {
        case .authorized:
            if cameraController.isConfigured {
                CameraPreviewView(session: cameraController.session)
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
    
    private func cycleFlash() {
        let modes = FlashMode.allCases
        guard let index = modes.firstIndex(of: flashMode) else { return }
        flashMode = modes[(index + 1) % modes.count]
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
