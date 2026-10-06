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
        [.original] + demoPresets + bundledPresets
    }

    public static let demoPresets: [LUTFilterPreset] = [
        LUTFilterPreset(id: "cinematic", name: "Cinematic"),
        LUTFilterPreset(id: "vintage", name: "Vintage"),
        LUTFilterPreset(id: "travel", name: "Travel"),
        LUTFilterPreset(id: "portrait", name: "Portrait"),
        LUTFilterPreset(id: "film", name: "Film"),
        LUTFilterPreset(id: "blackwhite", name: "Black & White")
    ]

    public static var bundledPresets: [LUTFilterPreset] {
        curatedResources
            .filter { bundledResourceURL(for: $0) != nil }
            .map { resourceName in
                return LUTFilterPreset(
                    id: resourceName,
                    name: displayName(for: resourceName),
                    intensity: 1.0,
                    lutResourceName: resourceName
                )
            }
    }

    static let bundledResourceNames: [String] = curatedResources

    private static let curatedResources: [String] = [
        // Clean
        "38_loot", "39_loot", "40_loot", "44_loot", "46_loot", "95_loot", "96_loot", "100_loot", "101_loot", "106_loot", "107_loot", "127_loot", "140_loot", "149_loot", "168_loot",
        // Golden
        "13_loot", "15_loot", "16_loot", "23_loot", "42_loot", "43_loot", "50_loot", "53_loot", "56_loot", "87_loot", "88_loot", "129_loot", "139_loot", "159_loot", "180_loot",
        // Coastal
        "10_loot", "11_loot", "24_loot", "25_loot", "47_loot", "48_loot", "54_loot", "58_loot", "62_loot", "65_loot", "66_loot", "73_loot", "74_loot", "134_loot", "147_loot",
        // Cinema
        "00_tron", "01_brooklyn", "02_ametrine", "03_sedona", "04_suicide_squad", "05_her_strong", "06_drive", "07_no_country", "08_casino_royal", "14_loot", "28_loot", "31_loot", "32_loot", "33_loot", "34_loot",
        // Film
        "29_loot", "57_loot", "59_loot", "60_loot", "61_loot", "63_loot", "75_loot", "79_loot", "82_loot", "92_loot", "93_loot", "122_loot", "138_loot", "164_loot", "178_loot",
        // Moody
        "19_loot", "20_loot", "26_loot", "27_loot", "35_loot", "36_loot", "37_loot", "45_loot", "76_loot", "77_loot", "90_loot", "136_loot", "145_loot", "165_loot", "175_loot",
        // Mono
        "12_loot", "17_loot", "18_loot", "78_loot", "111_loot", "121_loot", "124_loot", "128_loot", "144_loot", "152_loot", "155_loot", "162_loot", "170_loot", "179_loot", "182_loot",
        // Creative
        "21_loot", "30_loot", "86_loot", "89_loot", "102_loot", "103_loot", "104_loot", "105_loot", "133_loot", "135_loot", "137_loot", "156_loot", "157_loot", "169_loot", "173_loot"
    ]

    static func bundledResourceURL(for resourceName: String) -> URL? {
        Bundle.module.url(
            forResource: resourceName,
            withExtension: "png",
            subdirectory: "LUTs"
        ) ?? Bundle.module.url(
            forResource: resourceName,
            withExtension: "png"
        )
    }

    static func displayName(for resourceName: String) -> String {
        if let curatedName = curatedDisplayNames[resourceName] {
            return curatedName
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

    private static let curatedDisplayNames: [String: String] = [
        "38_loot": "Neutral", "39_loot": "Pure", "40_loot": "Daylight", "44_loot": "Balanced", "46_loot": "Airy", "95_loot": "Soft Light", "96_loot": "Linen", "100_loot": "Bright", "101_loot": "Radiant", "106_loot": "Soft Skin", "107_loot": "Fresh", "127_loot": "Porcelain", "140_loot": "Natural", "149_loot": "Gentle", "168_loot": "Clear",
        "13_loot": "Amber", "15_loot": "Honey", "16_loot": "Apricot", "23_loot": "Golden Hour", "42_loot": "Warm Sand", "43_loot": "Terracotta", "50_loot": "Sunlit", "53_loot": "Glow", "56_loot": "Candlelight", "87_loot": "Sepia", "88_loot": "Sunkissed", "129_loot": "Ember", "139_loot": "Bronze", "159_loot": "Vintage Gold", "180_loot": "Heat",
        "10_loot": "Aqua", "11_loot": "Ocean", "24_loot": "Blue Bay", "25_loot": "Lagoon", "47_loot": "Salt Air", "48_loot": "Sea Glass", "54_loot": "Breeze", "58_loot": "Shoreline", "62_loot": "Marine", "65_loot": "Azure", "66_loot": "Tide", "73_loot": "Tropic", "74_loot": "Island", "134_loot": "Electric Blue", "147_loot": "Arctic",
        "00_tron": "Neon Night", "01_brooklyn": "Borough", "02_ametrine": "Violet Stone", "03_sedona": "Desert", "04_suicide_squad": "Rogue", "05_her_strong": "Warm Future", "06_drive": "Night Drive", "07_no_country": "Dust", "08_casino_royal": "Royal Blue", "14_loot": "Blockbuster", "28_loot": "Steel Orange", "31_loot": "Thriller", "32_loot": "Drama", "33_loot": "Chrome", "34_loot": "Epic",
        "29_loot": "Matte", "57_loot": "Soft Fade", "59_loot": "Paper", "60_loot": "Silver Fade", "61_loot": "Faded Color", "63_loot": "Muted", "75_loot": "Washed", "79_loot": "Dusty", "82_loot": "Analog", "92_loot": "Nostalgia", "93_loot": "Negative", "122_loot": "Retro", "138_loot": "Classic", "164_loot": "Aged", "178_loot": "Archive",
        "19_loot": "Shadow", "20_loot": "Eclipse", "26_loot": "Storm", "27_loot": "Slate", "35_loot": "After Dark", "36_loot": "Dusk", "37_loot": "Hollow", "45_loot": "Rain", "76_loot": "Red Night", "77_loot": "Cold Night", "90_loot": "Deep Blue", "136_loot": "Plum", "145_loot": "Forest", "165_loot": "Nocturne", "175_loot": "Winter",
        "12_loot": "Ash", "17_loot": "Pearl", "18_loot": "Classic BW", "78_loot": "Crimson BW", "111_loot": "Soft Silver", "121_loot": "Silver", "124_loot": "Cool BW", "128_loot": "Soft BW", "144_loot": "Emerald BW", "152_loot": "Blue Steel", "155_loot": "Graphite", "162_loot": "Warm Gray", "170_loot": "Sepia BW", "179_loot": "Carbon", "182_loot": "Hard BW",
        "21_loot": "Acid", "30_loot": "Mirage", "86_loot": "Rose Shift", "89_loot": "Ultraviolet", "102_loot": "Lime Pop", "103_loot": "Cross Process", "104_loot": "Jungle Pop", "105_loot": "Hyper Green", "133_loot": "Electric Violet", "135_loot": "Candy", "137_loot": "Solar", "156_loot": "Neon Teal", "157_loot": "Neon Orange", "169_loot": "Lavender", "173_loot": "Poster Red"
    ]
}
