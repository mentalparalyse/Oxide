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

