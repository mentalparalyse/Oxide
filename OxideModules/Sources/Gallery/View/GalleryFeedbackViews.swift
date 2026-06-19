// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import SwiftUI
import UIComponents

struct DeleteConfirmationView: View {
    @ObservedObject var presenter: GalleryPresenter
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture(perform: presenter.cancelDelete)
            
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text("Delete this photo?")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppColours.appForegroundColor)
                    Text("This can't be undone.")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColours.appMutedForegroundColor)
                }
                .padding(.vertical, 24)
                
                Divider().background(AppColours.appBorderColor)
                
                Button("Delete", action: presenter.confirmDeleteSelectedPhoto)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColours.appDestructiveColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                
                Divider().background(AppColours.appBorderColor)
                
                Button("Cancel", action: presenter.cancelDelete)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColours.appForegroundColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .background(AppColours.appSurfaceColor, in: RoundedRectangle(cornerRadius: 24))
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
    }
}

struct GalleryToastView: View {
    let toast: GalleryToast
    
    var body: some View {
        Text(toast.message)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(AppColours.appForegroundColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(toastBackground, in: Capsule())
            .padding(.top, 16)
            .frame(maxHeight: .infinity, alignment: .top)
    }
    
    private var toastBackground: Color {
        switch toast {
        case .success:
            AppColours.buttonBacground
        case .error:
            AppColours.appDestructiveColor
        }
    }
}
