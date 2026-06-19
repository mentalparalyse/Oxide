// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Foundation

public struct LUTFilterPreset: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let intensity: Double
    public let lutResourceName: String?
    
    public init(id: String, name: String, intensity: Double = 1.0, lutResourceName: String? = nil) {
        self.id = id
        self.name = name
        self.intensity = intensity
        self.lutResourceName = lutResourceName
    }
    
    public static let original = LUTFilterPreset(id: "original", name: "Original", intensity: 0)
    
    public static var all: [LUTFilterPreset] {
        [.original] + bundledPresets
    }
    
    public static var bundledPresets: [LUTFilterPreset] {
        bundledResourceNames
            .filter { $0 != "00_clear" }
            .map { resourceName in
                return LUTFilterPreset(
                    id: resourceName,
                    name: displayName(for: resourceName),
                    intensity: 1.0,
                    lutResourceName: resourceName
                )
            }
    }
    
    static let bundledResourceNames: [String] = namedResousces + presetResources
    
    static let namedResousces: [String] = [
        "00_clear", "00_tron", "01_brooklyn", "02_ametrine", "03_sedona", "04_suicide_squad",
        "05_her_strong", "06_drive", "07_no_country", "08_casino_royal", "10_loot", "11_loot",
    ]
    
    static let presetResources: [String] = (12...120).map { "\($0)_loot" }
    
    static func bundledResourceURL(for resourceName: String) -> URL? {
        Bundle.module.url(
            forResource: resourceName,
            withExtension: "png",
            subdirectory: "FilterImgs2"
        ) ?? Bundle.module.url(
            forResource: resourceName,
            withExtension: "png"
        )
    }
    
    private static func displayName(for resourceName: String) -> String {
        if let themedName = themedDisplayName(for: resourceName) {
            return themedName
        }
        
        let parts = resourceName
            .split(separator: "_")
            .dropFirst()
        
        let rawName = parts.isEmpty ? resourceName : parts.joined(separator: " ")
        return rawName
            .split(separator: " ")
            .map { word in
                word.prefix(1).uppercased() + word.dropFirst()
            }
            .joined(separator: " ")
    }
    
    private static func themedDisplayName(for resourceName: String) -> String? {
        guard
            resourceName.hasSuffix("_loot"),
            let numberText = resourceName.split(separator: "_").first,
            let number = Int(numberText)
        else {
            return nil
        }
        
        let themes = [
            "Cinematic", "Vintage", "Travel", "Portrait", "Film",
            "Noir", "Urban", "Sunset", "Editorial", "Dream"
        ]
        let index = max(number - 10, 0)
        let theme = themes[min(index / 12, themes.count - 1)]
        let sequence = (index % 12) + 1
        return "\(theme) \(String(format: "%02d", sequence))"
    }
}
