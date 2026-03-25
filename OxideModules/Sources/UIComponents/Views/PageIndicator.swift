// Copyright (c) 2026 and Confidential to SoftFusion All rights reserved.

import SwiftUI
 
public struct PageIndicator: View {
    
    @Namespace private var indicatorNamespace
    @Binding private var currentPage: Int
    private let numberOfPages: Int
    
    public init(currentPage: Binding<Int>, numberOfPages: Int) {
        self._currentPage = currentPage
        self.numberOfPages = numberOfPages
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                ZStack {
                    if index == currentPage {
                        Capsule()
                            .fill(.white)
                            .matchedGeometryEffect(
                                id: "indicator",
                                in: indicatorNamespace
                            )
                            .frame(width: 16, height: 8)
                    } else {
                        Circle()
                            .fill( Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.8), value: currentPage)
            }
        }
    }
}
