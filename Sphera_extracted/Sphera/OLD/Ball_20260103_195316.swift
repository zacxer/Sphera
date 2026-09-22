//
//  Ball.swift
//  BallSortPuzzle
//
//  Created on 2026-01-02.
//

import SwiftUI

enum BallColor: Int, CaseIterable, Codable {
    case red = 0
    case blue = 1
    case green = 2
    case yellow = 3
    case purple = 4
    case orange = 5
    case pink = 6
    case cyan = 7

    var color: Color {
        switch self {
        case .red: return Color.ballRed
        case .blue: return Color.ballBlue
        case .green: return Color.ballGreen
        case .yellow: return Color.ballYellow
        case .purple: return Color.ballPurple
        case .orange: return Color(hex: "FF8C00")
        case .pink: return Color(hex: "FF69B4")
        case .cyan: return Color(hex: "00CED1")
        }
    }

    var highlightColor: Color {
        switch self {
        case .red: return Color(hex: "FF8A8A")
        case .blue: return Color(hex: "7B8AFF")
        case .green: return Color(hex: "7DFFB3")
        case .yellow: return Color(hex: "FFE066")
        case .purple: return Color(hex: "C99AFF")
        case .orange: return Color(hex: "FFB366")
        case .pink: return Color(hex: "FFB6D9")
        case .cyan: return Color(hex: "66FFFF")
        }
    }
}

struct Ball: Identifiable, Equatable, Codable {
    let id: UUID
    let ballColor: BallColor

    init(id: UUID = UUID(), color: BallColor) {
        self.id = id
        self.ballColor = color
    }

    static func == (lhs: Ball, rhs: Ball) -> Bool {
        lhs.id == rhs.id && lhs.ballColor == rhs.ballColor
    }
}
