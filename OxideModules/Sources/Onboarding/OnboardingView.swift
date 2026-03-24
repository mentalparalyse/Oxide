// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import SwiftUI
import UIComponents

public struct OnboardingView: View {
    
    @StateObject var presenter: OnboardingPresenter
    
    public init(presenter: OnboardingPresenter) {
        self._presenter = StateObject(wrappedValue: presenter)
    }
    
    public var body: some View {
        ZStack {
            AppColours.appColor
                .edgesIgnoringSafeArea(.all)
            content
        }
        .navigationBarStyle(.default)
    }
    
    @ViewBuilder
    private var content: some View {
        VStack(spacing: 8) {
            Spacer()
            OnboardingCarouselView(
                currentIndex: $presenter.currentPage,
                pages: presenter.pages
            )
            Spacer()
            continueButton
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .foregroundStyle(AppColours.appForegroundColor)
    }
    
    
    private var continueButton: some View {
        Button {
            presenter.finish()
        } label: {
            HStack {
                Text("Get Started")
                    .font(AppFonts.large)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppColours.buttonBacground.clipShape(Capsule()))
        }
        .padding(.horizontal, 16)
    }
}


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
                .fill(Color(hex: 0xFF6B35))
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
