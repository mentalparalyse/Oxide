// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import SwiftUI
import UIComponents

struct OxideMarkView: View {
    var revealProgress: Double = 1
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.black.opacity(0.28))
                .frame(width: 164, height: 164)
                .shadow(color: AppColours.buttonBacground.opacity(0.22), radius: 32)
            
            Circle()
                .trim(from: 0.04, to: 0.94)
                .stroke(
                    AngularGradient(
                        colors: [
                            AppColours.buttonBacground,
                            Color(hex: 0xF4B35E),
                            Color(hex: 0x44D7B6),
                            AppColours.buttonBacground
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 18, lineCap: .round)
                )
                .rotationEffect(.degrees(-102 + revealProgress * 36))
                .frame(width: 132, height: 132)
                .shadow(color: AppColours.buttonBacground.opacity(0.22), radius: 18)
            
            ApertureBladesView(progress: revealProgress)
                .frame(width: 90, height: 90)
            
            LUTStripView(progress: revealProgress)
                .frame(width: 58, height: 58)
                .offset(x: 42, y: 42)
        }
        .accessibilityHidden(true)
    }
}

private struct ApertureBladesView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { index in
                Capsule()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 14, height: 54)
                    .offset(y: -18)
                    .rotationEffect(.degrees(Double(index) * 60 + progress * 10))
            }
            
            Circle()
                .fill(AppColours.appColor)
                .frame(width: 44, height: 44)
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                }
        }
    }
}

private struct LUTStripView: View {
    let progress: Double
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(Array(colors.enumerated()), id: \.offset) { _, color in
                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
                    .frame(width: 7, height: 34)
            }
        }
        .padding(7)
        .background(.black.opacity(0.45), in: RoundedRectangle(cornerRadius: 10))
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.18))
                .frame(width: 12)
                .offset(x: CGFloat(progress) * 52 - 10)
                .blur(radius: 1)
                .blendMode(.screen)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private var colors: [Color] {
        [
            AppColours.buttonBacground,
            Color(hex: 0xF4B35E),
            Color(hex: 0x44D7B6),
            Color(hex: 0xFFFFFF)
        ]
    }
}
