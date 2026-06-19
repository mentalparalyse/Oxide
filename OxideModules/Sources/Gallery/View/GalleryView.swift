// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import SwiftUI
import UIComponents

public struct GalleryView: View {
    @StateObject var presenter: GalleryPresenter
    
    public init(presenter: GalleryPresenter) {
        self._presenter = StateObject(wrappedValue: presenter)
    }
    
    public var body: some View {
        ZStack {
            AppColours.appColor
                .ignoresSafeArea()
            
            screenContent
            
            if presenter.isDeleteConfirmationPresented {
                DeleteConfirmationView(presenter: presenter)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            if let toast = presenter.toast {
                GalleryToastView(toast: toast)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .task(id: toast.message) {
                        try? await Task.sleep(nanoseconds: 3_000_000_000)
                        presenter.clearToast()
                    }
            }
        }
        .animation(.easeOut(duration: 0.2), value: presenter.screen)
        .animation(.easeOut(duration: 0.2), value: presenter.isDeleteConfirmationPresented)
        .navigationBarStyle(.default)
    }
    
    @ViewBuilder
    private var screenContent: some View {
        switch presenter.screen {
        case .gallery:
            GalleryGridView(presenter: presenter)
        case .preview:
            if let photo = presenter.selectedPhoto {
                GalleryPreviewView(photo: photo, presenter: presenter)
            } else {
                GalleryGridView(presenter: presenter)
            }
        case .capture:
            GalleryCaptureView(presenter: presenter)
        case .editing:
            if presenter.draft != nil {
                GalleryEditingView(presenter: presenter)
            } else {
                GalleryGridView(presenter: presenter)
            }
        }
    }
}
