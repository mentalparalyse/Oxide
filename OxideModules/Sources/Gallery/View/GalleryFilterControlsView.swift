// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import SwiftUI
import UIComponents

struct FilterIntensitySlider: View {
    let value: Double
    let onChange: (Double) -> Void
    let onChangeEnded: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Text("Intensity")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppColours.appMutedForegroundColor)
            
            Slider(value: Binding(
                get: { value },
                set: { newValue in
                    onChange(newValue)
                }
            ), in: 0...1, onEditingChanged: { isEditing in
                if !isEditing {
                    onChangeEnded()
                }
            })
            .tint(AppColours.buttonBacground)
            
            Text("\(Int(value * 100))")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppColours.appForegroundColor)
                .frame(width: 32, alignment: .trailing)
        }
    }
}
