// Copyright (c) 2026 and Confidential to SoftFusion All rights reserved.

import SwiftUI

struct AdjustableContainerView<Content: View>: View {
    var content: () -> Content
    
    
    
    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    AdjustableContainerView {
        Text("Hello world")
    }
}
