// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import SwiftUI
import UIComponents

struct GalleryPreviewView: View {
    let photo: GalleryPhoto
    @ObservedObject var presenter: GalleryPresenter

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            LUTPreviewImage(
                imageURL: photo.imageURI,
                presetID: photo.filterID,
                intensity: photo.filterIntensity,
                rotationDegrees: photo.rotationDegrees,
                crop: photo.crop,
                adjustments: photo.adjustments,
                contentMode: .fit
            )
            .padding(.horizontal, 4)

            VStack {
                HStack {
                    CircleIconButton(systemName: "xmark", label: "Close", action: presenter.dismissPreview)
                    Spacer()
                    CircleIconButton(systemName: "ellipsis", label: "More options", action: presenter.showSelectedPhotoInfo)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                Spacer()

                HStack {
                    PreviewActionButton(systemName: "pencil", title: "Edit") {
                        Task { await presenter.startEditingSelectedPhoto() }
                    }
                    PreviewActionButton(systemName: "square.and.arrow.up", title: "Share") {
                        Task { await presenter.shareSelectedPhoto() }
                    }
                    .disabled(presenter.isPreparingShare)
                    PreviewActionButton(
                        systemName: presenter.previewSaveState == .saved ? "checkmark" : "square.and.arrow.down",
                        title: presenter.previewSaveState == .saved ? "Saved" : "Save"
                    ) {
                        Task { await presenter.saveSelectedPhotoToLibrary() }
                    }
                    .disabled(presenter.previewSaveState != .idle)
                    PreviewActionButton(
                        systemName: "trash",
                        title: "Delete",
                        foreground: AppColours.appDestructiveColor,
                        background: AppColours.appDestructiveColor.opacity(0.2),
                        action: presenter.requestDeleteSelectedPhoto
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            }
        }
        .sheet(isPresented: $presenter.isInfoPresented) {
            if let info = presenter.selectedPhotoInfo {
                GalleryPhotoInfoView(info: info)
                    .presentationDetents([.height(infoSheetHeight(for: info))])
            }
        }
    }

    private func infoSheetHeight(for info: GalleryPhotoInfo) -> CGFloat {
        var height: CGFloat = 180
        height += 70
        if let originalDimensions = info.originalDimensions,
           let editedDimensions = info.editedDimensions,
           originalDimensions != editedDimensions {
            height += 70
        }
        if info.filterName != nil { height += 80 }
        return height
    }
}
