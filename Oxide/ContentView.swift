//
//  ContentView.swift
//  Oxide
//
//  Created by Lex Sava on 08.09.2025.
//

import SwiftUI
import Lottie

struct ContentView: View {
    
    var body: some View {
        VStack {
            Text("haha")
            lottieView
                .frame(width: 250, height: 250)
        }
        .padding()
    }
    
    var lottieView: some View {
        LottieView(animation: LottieAnimation.named("oxide_splash"))
            .playbackMode(
                .playing(
                    .fromProgress(
                        0.0,
                        toProgress: 1.0,
                        loopMode: .playOnce
                    )
                )
            )
            .animationDidFinish { completed in
                if completed {
                    print("completed")
                }
            }
    }
}

#Preview {
    ContentView()
}
