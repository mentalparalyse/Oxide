// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import UIComponents
import SwiftUI

public struct SplashView: View {
    @StateObject var presenter: SplashPresenter
    @State private var isVisible = false
    @State private var revealProgress = 0.0
    
    init(presenter: SplashPresenter) {
        self._presenter = .init(wrappedValue: presenter)
    }
    
    public var body: some View {
        ZStack {
            AppColours.appColor
                .ignoresSafeArea()
            
            VStack(spacing: 22) {
                OxideMarkView(revealProgress: revealProgress)
                    .scaleEffect(isVisible ? 1 : 0.92)
                    .opacity(isVisible ? 1 : 0)
                
                Text("OXIDE")
                    .font(.system(size: 30, weight: .semibold, design: .default))
                    .foregroundStyle(AppColours.appForegroundColor)
                    .shadow(color: AppColours.buttonBacground.opacity(0.28), radius: 24)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 8)
            }
        }
        .task {
            await playIntro()
        }
    }
    
    private func playIntro() async {
        withAnimation(.spring(response: 0.46, dampingFraction: 0.82)) {
            isVisible = true
        }
        
        withAnimation(.easeInOut(duration: 0.78)) {
            revealProgress = 1
        }
        
        try? await Task.sleep(nanoseconds: 950_000_000)
        presenter.finish()
    }
}
