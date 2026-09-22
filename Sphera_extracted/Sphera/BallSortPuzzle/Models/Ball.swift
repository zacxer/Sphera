//
//  Ball.swift
//  BallSortPuzzle
//
//  Created on 2026-01-02.
//  Updated: 2026-01-03 - Added ShapeType for Phase 3
//

import SwiftUI

// MARK: - Ball Color

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

    var shadowColor: Color {
        switch self {
        case .red: return Color(hex: "8B0000")
        case .blue: return Color(hex: "00008B")
        case .green: return Color(hex: "006400")
        case .yellow: return Color(hex: "B8860B")
        case .purple: return Color(hex: "4B0082")
        case .orange: return Color(hex: "8B4500")
        case .pink: return Color(hex: "8B0A50")
        case .cyan: return Color(hex: "008B8B")
        }
    }
}

// MARK: - Shape Type (FASE 3)

enum ShapeType: Int, CaseIterable, Codable {
    case ball = 0      // Pallina (default)
    case cube = 1      // Cubo
    case pyramid = 2   // Piramide
    case star = 3      // Stella
    case diamond = 4   // Diamante

    var icon: String {
        switch self {
        case .ball: return "circle.fill"
        case .cube: return "square.fill"
        case .pyramid: return "triangle.fill"
        case .star: return "star.fill"
        case .diamond: return "diamond.fill"
        }
    }

    var displayName: String {
        switch self {
        case .ball: return L10n.current == .italian ? "Pallina" : "Ball"
        case .cube: return L10n.current == .italian ? "Cubo" : "Cube"
        case .pyramid: return L10n.current == .italian ? "Piramide" : "Pyramid"
        case .star: return L10n.current == .italian ? "Stella" : "Star"
        case .diamond: return L10n.current == .italian ? "Diamante" : "Diamond"
        }
    }
}

// MARK: - Ball (GamePiece)

struct Ball: Identifiable, Equatable, Codable {
    let id: UUID
    let ballColor: BallColor
    let shape: ShapeType

    init(id: UUID = UUID(), color: BallColor, shape: ShapeType = .ball) {
        self.id = id
        self.ballColor = color
        self.shape = shape
    }

    // MARK: - Stacking Rules (FASE 3)

    /// Due pezzi possono stare insieme se hanno stesso COLORE o stessa FORMA
    func canStackWith(_ other: Ball) -> Bool {
        return self.ballColor == other.ballColor || self.shape == other.shape
    }

    /// Due pezzi sono identici se hanno stesso COLORE E stessa FORMA
    func isIdenticalTo(_ other: Ball) -> Bool {
        return self.ballColor == other.ballColor && self.shape == other.shape
    }

    // MARK: - Equatable

    static func == (lhs: Ball, rhs: Ball) -> Bool {
        lhs.id == rhs.id && lhs.ballColor == rhs.ballColor && lhs.shape == rhs.shape
    }
}

// MARK: - Alias per retrocompatibilità

typealias GamePiece = Ball
