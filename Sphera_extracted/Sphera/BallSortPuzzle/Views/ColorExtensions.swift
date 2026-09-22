//
//  ColorExtensions.swift
//  BallSortPuzzle
//
//  Created on 2026-01-02.
//

import SwiftUI

extension Color {
    // Ball Colors (dalla palette del design)
    static let ballRed = Color(hex: "FF4757")
    static let ballBlue = Color(hex: "3742FA")
    static let ballGreen = Color(hex: "2ED573")
    static let ballYellow = Color(hex: "FFC312")
    static let ballPurple = Color(hex: "A55EEA")

    // Background Colors
    static let backgroundDark = Color(hex: "1A1A2E")
    static let backgroundLight = Color(hex: "16213E")

    // Helper init from hex
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
