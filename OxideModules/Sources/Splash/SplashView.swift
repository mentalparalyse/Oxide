// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import UIComponents
import Lottie
import SwiftUI

public struct SplashView: View {
    @StateObject var presenter: SplashPresenter
    
    init(presenter: SplashPresenter) {
        self._presenter = .init(wrappedValue: presenter)
    }
    
    public var body: some View {
        ZStack {
            AppColours.appColor
                .ignoresSafeArea()
            LottieView(animation: .named("oxide_splash", bundle: .main))
                .playing()
                .animationDidFinish { completed in
                    presenter.finish()
                }
        }
    }
}
