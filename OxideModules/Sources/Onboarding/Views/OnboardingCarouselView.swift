// Copyright (c) 2026 and Confidential to SoftFusion All rights reserved.

import SwiftUI
import UIComponents

struct OnboardingCarouselView: View {
    @Binding var currentIndex: Int
    let pages: [OnboardingItem]
    
    var body: some View {
        VStack(spacing: 35) {
            TabView(selection: $currentIndex) {
                ForEach(Array(pages.enumerated()), id: \.offset) { model in
                    buildPage(model.element)
                        .tag(model.offset)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 200)
            
            PageIndicator(
                currentPage: $currentIndex,
                numberOfPages: pages.count
            )
            
            Text(currentModel.title)
                .font(AppFonts.extraLarge)
                .foregroundStyle(.white)
            
            Text(currentModel.description)
                .font(AppFonts.largeMedium)
                .foregroundStyle(Color(hex: 0x8E8E93))
        }
    }
    
    @ViewBuilder
    private func buildPage(_ model: OnboardingItem) -> some View {
        ZStack {
            Circle()
                .fill(AppColours.accent)
                .opacity(0.25)
            Image(model.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 63)
        }
        .frame(width: 125, height: 125)
    }
    
    private var currentModel: OnboardingItem {
        pages[currentIndex]
    }
}
