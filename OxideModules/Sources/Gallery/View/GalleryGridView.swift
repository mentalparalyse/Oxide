// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import PhotosUI
import SwiftUI
import UIComponents

struct GalleryGridView: View {
    @ObservedObject var presenter: GalleryPresenter
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            if presenter.photos.isEmpty {
                EmptyGalleryView(openCapture: presenter.openCapture)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(presenter.photos, id: \.id) { photo in
                            PhotoThumbnailView(photo: photo) {
                                presenter.selectPhoto(photo)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 92)
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Button(action: presenter.openCapture) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(AppColours.appForegroundColor)
                    .frame(width: 56, height: 56)
                    .background(AppColours.buttonBacground, in: Circle())
                    .shadow(color: .black.opacity(0.35), radius: 12, y: 6)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Take new photo")
            .padding(.trailing, 16)
            .padding(.bottom, 24)
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
    
    private var header: some View {
        HStack {
            Text("Oxide")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(AppColours.appForegroundColor)
            
            Spacer()
            
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(AppColours.appForegroundColor)
                    .frame(width: 40, height: 40)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Import photo")
            
            Button(action: presenter.openCapture) {
                Image(systemName: "camera")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(AppColours.appForegroundColor)
                    .frame(width: 40, height: 40)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open camera")
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 10)
    }
}

private struct EmptyGalleryView: View {
    let openCapture: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Button(action: openCapture) {
                Image(systemName: "plus")
                    .font(.system(size: 44, weight: .regular))
                    .foregroundStyle(AppColours.appBorderColor)
                    .frame(width: 192, height: 192)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                AppColours.appBorderColor,
                                style: StrokeStyle(lineWidth: 2, dash: [8, 8])
                            )
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Capture first photo")
            
            Text("No photos yet")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(AppColours.appForegroundColor)
                .padding(.top, 24)
            
            Text("Tap to capture your first moment")
                .font(.system(size: 16))
                .foregroundStyle(AppColours.appMutedForegroundColor)
                .padding(.top, 8)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 32)
    }
}

private struct PhotoThumbnailView: View {
    let photo: GalleryPhoto
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            GalleryThumbnailImage(
                url: photo.imageURI,
                maxPixelSize: 480
            )
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fill)
            .clipped()
            .background(AppColours.appSurfaceColor)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open photo")
    }
}
