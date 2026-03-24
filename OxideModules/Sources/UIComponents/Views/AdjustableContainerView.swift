// Copyright (c) 2026 and Confidential to SoftFusion All rights reserved.

import SwiftUI

public struct AdjustableContainerView<Content: View>: View {
    var content: () -> Content
    
    public init(content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        VStack {
            content()
                .padding(16)
        }
        .frame(maxWidth: .infinity)
        .background(Color.red)
        
    }
}

#Preview {
    AdjustableContainerView {
        Text("Hello world")
    }
}
