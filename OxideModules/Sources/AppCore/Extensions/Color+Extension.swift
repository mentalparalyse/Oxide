//
//  Color+Extension.swift
//  Oxide
//
//  Created by Lex Sava on 10.09.2025.
//

import SwiftUI

public extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        let r = Double((hex & 0xFF0000) >> 16) / 255.0
        let g = Double((hex & 0x00FF00) >> 8) / 255.0
        let b = Double(hex & 0x0000FF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
