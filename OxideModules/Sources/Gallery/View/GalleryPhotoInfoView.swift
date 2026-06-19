// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import SwiftUI
import UIComponents

struct GalleryPhotoInfoView: View {
    let info: GalleryPhotoInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Photo info")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(AppColours.appForegroundColor)
            
            infoRow(title: "Captured", value: info.capturedAt.formatted(date: .abbreviated, time: .shortened))
            
            if let filterName = info.filterName, let filterIntensity = info.filterIntensity {
                infoRow(title: "Filter", value: filterName)
                infoRow(title: "Intensity", value: "\(Int(filterIntensity * 100))%")
            }
            
            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColours.appColor)
    }
    
    private func infoRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppColours.appMutedForegroundColor)
            Text(value)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppColours.appForegroundColor)
        }
    }
}
