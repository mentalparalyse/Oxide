// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.


import SwiftUI

public enum AppColours {
    ///App background colour
    public static let appColor = Color(hex: 0x0A0A0A)
    ///Secondary app surface colour
    public static let appSurfaceColor = Color(hex: 0x1C1C1E)
    ///Muted text colour
    public static let appMutedForegroundColor = Color(hex: 0x8E8E93)
    ///Divider and inactive border colour
    public static let appBorderColor = Color(hex: 0x3A3A3C)
    ///Destructive action colour
    public static let appDestructiveColor = Color(hex: 0xFF453A)
    ///Colour applied to custom navigation title. .
    public static let navigationForegroundColor = Color(hex: 0x44D7B6)
    ///Colour applied to all texts in app.
    public static let appForegroundColor = Color.white
    ///Color applied to buttons background
    public static let buttonBacground = Color(hex: 0xFF6B35)
}

///App uses system font as main so to make it easier to access I've created this enum
public enum AppFonts {
    ///Small system font *12px*
    public static let small = Font.system(size: 12, weight: .regular, design: .monospaced)
    ///Medium system font *14px*
    public static let medium = Font.system(size: 14, weight: .thin, design: .monospaced)
    ///Large system font *16px*
    public static let large = Font.system(size: 16, weight: .bold, design: .monospaced)
    ///Large system font with medium weight *16px*
    public static let largeMedium = Font.system(size: 16, weight: .bold, design: .monospaced)
    ///Extra large font *32px*
    public static let extraLarge = Font.system(size: 24, weight: .bold, design: .monospaced)
}
