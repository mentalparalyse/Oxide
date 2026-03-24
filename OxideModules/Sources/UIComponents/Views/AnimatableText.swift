// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import SwiftUI

public struct AnimatableText: View {
    public typealias Completion = () -> Void

    public let text: String
    public var animationSpeed: Double
    public var delayMultiplier: Double
    public var onAnimationCompleted: Completion?

    @State private var textToAnimate = ""
    @State private var hasAnimated = false

    public init(
        text: String,
        animationSpeed: Double = 1.25,
        delayMultiplier: Double = 0.2,
        onAnimationCompleted: Completion? = nil
    ) {
        self.text = text
        self.animationSpeed = animationSpeed
        self.delayMultiplier = delayMultiplier
        self.onAnimationCompleted = onAnimationCompleted
    }

    public var body: some View {
        Text(textToAnimate)
            .contentTransition(.numericText())
            .animation(.linear.speed(animationSpeed), value: textToAnimate)
            .onAppear {
                guard !hasAnimated else { return }
                hasAnimated = true
                animate()
            }
    }

    private func animate() {
        textToAnimate = ""

        let chars = Array(text)
        let lastIndex = chars.indices.last ?? 0

        for (i, c) in chars.enumerated() {
            let delay = Double(i) * delayMultiplier

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.linear.speed(animationSpeed)) {
                    textToAnimate.append(c)
                }

                if i == lastIndex {
                    DispatchQueue.main.async {
                        onAnimationCompleted?()
                    }
                }
            }
        }
    }
}

