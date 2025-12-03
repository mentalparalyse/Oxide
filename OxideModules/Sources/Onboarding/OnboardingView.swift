// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import SwiftUI
import AppCore
import Lottie

public struct OnboardingView: View {
    
    @StateObject var presenter: OnboardingPresenter
    
    public init(presenter: OnboardingPresenter) {
        self._presenter = StateObject(wrappedValue: presenter)
    }
    
    public var body: some View {
        ZStack(alignment: .leading) {
            AppColours.appColor
                .edgesIgnoringSafeArea(.all)
            content
        }
        .navigationBarStyle(.default)
    }
    
    @ViewBuilder
    private var content: some View {
        VStack(alignment: .leading, spacing: 8) {
            Spacer()
            Text("Welcome to Oxide")
                .font(AppFonts.medium)
            Text("Apply cinematic colour with fast, native processing.")
                .font(AppFonts.medium)
            Spacer()
            Button {
                presenter.finish()
            } label: {
                HStack {
                    Spacer()
                    Text("Get Started")
                        .font(AppFonts.small)
                    Spacer()
                }
                .padding(.vertical, 8)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            AppColours.navigationForegroundColor,
                            lineWidth: 2
                        )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .foregroundStyle(AppColours.appForegroundColor)
    }
}
