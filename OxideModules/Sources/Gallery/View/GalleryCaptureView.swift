// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import AVFoundation
import ImageProcessor
import PhotosUI
import SwiftUI
import UIComponents

struct GalleryCaptureView: View {
    @ObservedObject var presenter: GalleryPresenter
    @StateObject private var cameraController = CameraSessionController()
    @State private var isTorchEnabled = false
    @State private var isGridEnabled = false
    @State private var isShutterAnimating = false
    @State private var isCaptureFlashVisible = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var exposureBias = 0.0
    @State private var selectedAspect: CameraAspectRatio = .fourThree
    @State private var focusPoint: CGPoint?
    @State private var isExposureVisible = false
    @State private var exposureHideTask: Task<Void, Never>?
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                cameraSurface
                if isCaptureFlashVisible { Color.white.ignoresSafeArea().transition(.opacity) }
                VStack {
                    topControls
                    Spacer()
                    if isExposureVisible {
                        exposureControl
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
            }
            bottomControls
        }
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            cameraController.requestAccessAndConfigure()
        }
        .onDisappear {
            isTorchEnabled = false
            exposureHideTask?.cancel()
            cameraController.stopRunning()
        }
        .onChange(of: selectedPhotoItem) { item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    await presenter.startEditingImportedPhoto(data: data)
                }
                selectedPhotoItem = nil
            }
        }
    }
    
    private var topControls: some View {
        HStack(spacing: 10) {
            CircularIconButton(systemName: "xmark", accessibilityLabel: "Close camera", size: 40, action: presenter.closeCapture)
            Spacer()
            Menu {
                ForEach(CameraAspectRatio.allCases) { aspect in
                    Button {
                        selectedAspect = aspect
                    } label: {
                        if selectedAspect == aspect { Label(aspect.rawValue, systemImage: "checkmark") }
                        else { Text(aspect.rawValue) }
                    }
                }
            } label: {
                Text(selectedAspect.rawValue)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColours.appForegroundColor)
                    .frame(minWidth: 40, minHeight: 40)
                    .background(.black.opacity(0.48), in: Circle())
            }
            .accessibilityLabel("Photo aspect ratio")
            if cameraController.isLowLightBoostAvailable {
                CircularIconButton(
                    systemName: cameraController.isLowLightBoostEnabled ? "moon.fill" : "moon",
                    accessibilityLabel: cameraController.isLowLightBoostEnabled ? "Turn night mode off" : "Turn night mode on",
                    size: 40
                ) { cameraController.setLowLightBoostEnabled(!cameraController.isLowLightBoostEnabled) }
            }
            CircularIconButton(
                systemName: isGridEnabled ? "grid" : "grid",
                accessibilityLabel: isGridEnabled ? "Hide composition grid" : "Show composition grid",
                size: 40
            ) {
                withAnimation(.easeInOut(duration: 0.18)) { isGridEnabled.toggle() }
            }
            .opacity(isGridEnabled ? 1 : 0.62)
            CircularIconButton(
                systemName: isTorchEnabled ? "bolt.fill" : "bolt.slash",
                accessibilityLabel: isTorchEnabled ? "Turn torch off" : "Turn torch on",
                size: 40,
                action: toggleTorch
            )
            .disabled(!cameraController.isTorchAvailable || cameraController.isSwitchingCamera)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }
    
    private var bottomControls: some View {
        HStack {
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(AppColours.appForegroundColor)
                    .frame(width: 56, height: 56)
                    .background(AppColours.buttonBacground, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Import photo")
            Spacer()
            Button {
                animateShutter()
                cameraController.capturePhoto(flashMode: .off, aspectRatio: selectedAspect) { url in
                    Task { await presenter.startEditingCapturedPhoto(uri: url) }
                }
            } label: {
                Circle().stroke(AppColours.appForegroundColor, lineWidth: 4).frame(width: 72, height: 72)
                    .overlay { Circle().fill(AppColours.appForegroundColor).frame(width: 56, height: 56) }
            }
            .scaleEffect(isShutterAnimating ? 0.86 : 1)
            .disabled(cameraController.authorizationState != .authorized || !cameraController.isConfigured || cameraController.isSwitchingCamera)
            .buttonStyle(.plain)
            .accessibilityLabel("Take photo")
            Spacer()
            CircularIconButton(
                systemName: "arrow.triangle.2.circlepath.camera",
                accessibilityLabel: "Switch camera",
                size: 40,
                action: switchCamera
            )
            .frame(width: 56, height: 56)
            .disabled(!cameraController.isCameraSwitchAvailable || cameraController.isSwitchingCamera)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.vertical, 28)
        .background(Color.black)
    }
    
    @ViewBuilder private var cameraSurface: some View {
        switch cameraController.authorizationState {
        case .authorized:
            if cameraController.isConfigured {
                GeometryReader { proxy in
                    CameraPreview(session: cameraController.session) { devicePoint, viewPoint in
                        cameraController.focus(at: devicePoint)
                        focusPoint = viewPoint
                        showExposureControl()
                        Task { @MainActor in
                            try? await Task.sleep(nanoseconds: 900_000_000)
                            withAnimation { focusPoint = nil }
                        }
                    }
                    .overlay {
                        if let focusPoint {
                            RoundedRectangle(cornerRadius: 4).stroke(.yellow, lineWidth: 1.5)
                                .frame(width: 64, height: 64).position(focusPoint)
                                .transition(.opacity.combined(with: .scale)).allowsHitTesting(false)
                        }
                    }
                    .overlay { aspectGuide(in: proxy.size) }
                    .contentShape(Rectangle())
                }
                .clipped()
            } else { cameraUnavailableView(message: cameraController.errorMessage ?? "Preparing camera") }
        case .notDetermined: cameraUnavailableView(message: "Camera permission required")
        case .denied, .restricted: cameraUnavailableView(message: "Camera access is disabled")
        }
    }
    
    private var exposureControl: some View {
        HStack(spacing: 10) {
            Image(systemName: "sun.min.fill")
            Slider(value: $exposureBias, in: -2...2, step: 0.1) { isEditing in
                if isEditing {
                    exposureHideTask?.cancel()
                } else {
                    scheduleExposureHide(after: 4)
                }
            }
            Image(systemName: "sun.max.fill")
        }
        .font(.system(size: 14)).foregroundStyle(.white).padding(.horizontal, 14)
        .frame(maxWidth: 260).frame(height: 40).background(.black.opacity(0.48), in: Capsule())
        .padding(.bottom, 12)
        .onChange(of: exposureBias) { cameraController.setExposureBias(Float($0)) }
    }
    
    @ViewBuilder private func aspectGuide(in size: CGSize) -> some View {
        let guideRect = captureGuideRect(in: size)
        if selectedAspect.ratio != nil {
            Path { path in
                path.addRect(CGRect(origin: .zero, size: size))
                path.addRect(guideRect)
            }
            .fill(.black.opacity(0.72), style: FillStyle(eoFill: true))
            Path(guideRect)
                .stroke(.white.opacity(0.65), lineWidth: 1)
                .allowsHitTesting(false)
        }
        if isGridEnabled {
            Path { path in
                for fraction in [CGFloat(1) / 3, CGFloat(2) / 3] {
                    let x = guideRect.minX + guideRect.width * fraction
                    path.move(to: CGPoint(x: x, y: guideRect.minY))
                    path.addLine(to: CGPoint(x: x, y: guideRect.maxY))
                    let y = guideRect.minY + guideRect.height * fraction
                    path.move(to: CGPoint(x: guideRect.minX, y: y))
                    path.addLine(to: CGPoint(x: guideRect.maxX, y: y))
                }
            }
            .stroke(.white.opacity(0.55), lineWidth: 0.75)
            .allowsHitTesting(false)
            .transition(.opacity)
        }
    }
    
    private func captureGuideRect(in size: CGSize) -> CGRect {
        guard let ratio = selectedAspect.ratio else {
            return CGRect(origin: .zero, size: size)
        }
        let desiredRatio = size.width < size.height ? 1 / ratio : ratio
        let guideWidth = min(size.width, size.height * desiredRatio)
        let guideHeight = min(size.height, size.width / desiredRatio)
        return CGRect(
            x: (size.width - guideWidth) / 2,
            y: (size.height - guideHeight) / 2,
            width: guideWidth,
            height: guideHeight
        )
    }
    
    private func cameraUnavailableView(message: String) -> some View {
        AppColours.appSurfaceColor.overlay {
            VStack(spacing: 12) {
                Image(systemName: "camera.viewfinder").font(.system(size: 56)).foregroundStyle(AppColours.appMutedForegroundColor)
                Text(message).font(.system(size: 16)).foregroundStyle(AppColours.appMutedForegroundColor)
                    .multilineTextAlignment(.center).padding(.horizontal, 24)
            }
        }
    }
    
    private func showExposureControl() {
        withAnimation(.easeOut(duration: 0.18)) { isExposureVisible = true }
        scheduleExposureHide(after: 4)
    }
    
    private func scheduleExposureHide(after seconds: UInt64) {
        exposureHideTask?.cancel()
        exposureHideTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: seconds * 1_000_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.25)) { isExposureVisible = false }
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
