//
//  Tube.swift
//  BallSortPuzzle
//
//  Created on 2026-01-02.
//

import Foundation
import SwiftUI

// MARK: - TubeType Enum

enum TubeType: String, Codable, CaseIterable {
    case normal
    case frozen      // Pallina in fondo congelata, si scongela dopo X mosse
    case tall        // Capacità 6 invece di 4
    case locked      // Bloccato finché non si sblocca
    case portalA     // Portale A (collegato a B)
    case portalB     // Portale B (collegato a A)
    case rotating    // Ogni X mosse le palline si invertono

    var capacity: Int {
        switch self {
        case .tall: return 6
        default: return 4
        }
    }

    var displayName: String {
        switch self {
        case .normal: return "Normale"
        case .frozen: return "Ghiacciato"
        case .tall: return "Alto"
        case .locked: return "Bloccato"
        case .portalA, .portalB: return "Portale"
        case .rotating: return "Rotante"
        }
    }

    var icon: String {
        switch self {
        case .normal: return "cylinder"
        case .frozen: return "snowflake"
        case .tall: return "arrow.up"
        case .locked: return "lock.fill"
        case .portalA, .portalB: return "arrow.triangle.2.circlepath"
        case .rotating: return "arrow.clockwise"
        }
    }

    var accentColor: Color {
        switch self {
        case .normal: return .clear
        case .frozen: return Color(hex: "00D4FF")
        case .tall: return Color(hex: "FFD700")
        case .locked: return Color(hex: "FF6B6B")
        case .portalA: return Color(hex: "A855F7")
        case .portalB: return Color(hex: "A855F7")
        case .rotating: return Color(hex: "F97316")
        }
    }
}

// MARK: - PortalColor (per distinguere coppie di portali)

enum PortalColor: String, CaseIterable, Codable {
    case purple
    case orange
    case cyan

    var color: Color {
        switch self {
        case .purple: return Color(hex: "A855F7")
        case .orange: return Color(hex: "F97316")
        case .cyan: return Color(hex: "06B6D4")
        }
    }
}

// MARK: - Tube Model

struct Tube: Identifiable, Equatable, Codable {
    let id: UUID
    var balls: [Ball]
    let type: TubeType

    // Stati specifici per tipo
    var freezeCountdown: Int?       // Per frozen: mosse rimanenti prima dello scongelamento
    var isLocked: Bool?             // Per locked: se è ancora bloccato
    var linkedPortalId: UUID?       // Per portal: ID del portale collegato
    var portalColor: PortalColor?   // Per portal: colore del portale
    var rotateCountdown: Int?       // Per rotating: mosse rimanenti prima della rotazione

    var capacity: Int { type.capacity }

    // MARK: - Init

    init(id: UUID = UUID(), balls: [Ball] = [], capacity: Int = 4) {
        // Init retrocompatibile per tubi normali
        self.id = id
        self.balls = balls
        self.type = capacity == 6 ? .tall : .normal
        self.freezeCountdown = nil
        self.isLocked = nil
        self.linkedPortalId = nil
        self.portalColor = nil
        self.rotateCountdown = nil
    }

    init(id: UUID = UUID(), balls: [Ball] = [], type: TubeType, portalColor: PortalColor? = nil) {
        self.id = id
        self.balls = balls
        self.type = type
        self.portalColor = portalColor

        // Inizializza stato in base al tipo
        switch type {
        case .frozen:
            self.freezeCountdown = 3
        case .locked:
            self.isLocked = true
        case .rotating:
            self.rotateCountdown = 2
        case .portalA, .portalB:
            self.portalColor = portalColor ?? .purple
        default:
            break
        }
    }

    // MARK: - Computed Properties

    var isEmpty: Bool {
        balls.isEmpty
    }

    var isFull: Bool {
        balls.count >= capacity
    }

    var topBall: Ball? {
        balls.last
    }

    var bottomBall: Ball? {
        balls.first
    }

    var isComplete: Bool {
        guard balls.count == capacity else { return false }
        guard let firstColor = balls.first?.ballColor else { return false }
        return balls.allSatisfy { $0.ballColor == firstColor }
    }

    var consecutiveTopBallsCount: Int {
        guard let topColor = topBall?.ballColor else { return 0 }
        var count = 0
        for ball in balls.reversed() {
            if ball.ballColor == topColor {
                count += 1
            } else {
                break
            }
        }
        return count
    }

    // MARK: - Special Tube States

    /// Per frozen: la pallina in CIMA è bloccata?
    var isTopBallFrozen: Bool {
        guard type == .frozen else { return false }
        return (freezeCountdown ?? 0) > 0 && !balls.isEmpty
    }

    /// Per locked: il tubo è ancora bloccato?
    var isTubeLocked: Bool {
        guard type == .locked else { return false }
        return isLocked ?? false
    }

    /// Per rotating: sta per ruotare?
    var isAboutToRotate: Bool {
        guard type == .rotating else { return false }
        return (rotateCountdown ?? 0) == 1
    }

    /// Verifica se è un portale
    var isPortal: Bool {
        type == .portalA || type == .portalB
    }

    // MARK: - Methods

    mutating func removeBall() -> Ball? {
        guard !isEmpty else { return nil }
        return balls.removeLast()
    }

    mutating func addBall(_ ball: Ball) -> Bool {
        guard !isFull else { return false }
        balls.append(ball)
        return true
    }

    /// Può accettare pallina considerando tipo speciale
    func canReceiveBall(_ ball: Ball) -> Bool {
        // Locked tube non può ricevere
        if isTubeLocked {
            return false
        }

        // Normal rules
        if isEmpty { return true }
        if isFull { return false }
        return topBall?.ballColor == ball.ballColor
    }

    /// Può rimuovere pallina considerando tipo speciale
    func canRemoveTop() -> Bool {
        if isEmpty { return false }

        // Locked: non può rimuovere
        if isTubeLocked {
            return false
        }

        // Frozen: la pallina in cima è congelata, non può essere rimossa
        if isTopBallFrozen {
            return false
        }

        return true
    }

    /// Decrementa countdown frozen
    mutating func decrementFreezeCountdown() {
        guard type == .frozen, let countdown = freezeCountdown, countdown > 0 else { return }
        freezeCountdown = countdown - 1
    }

    /// Sblocca il tubo locked
    mutating func unlock() {
        guard type == .locked else { return }
        isLocked = false
    }

    /// Decrementa countdown rotazione e ruota se necessario
    mutating func processRotation() -> Bool {
        guard type == .rotating, let countdown = rotateCountdown else { return false }

        if countdown <= 1 {
            // Ruota le palline
            balls.reverse()
            rotateCountdown = 2 // Reset
            return true // Ha ruotato
        } else {
            rotateCountdown = countdown - 1
            return false
        }
    }

    static func == (lhs: Tube, rhs: Tube) -> Bool {
        lhs.id == rhs.id && lhs.balls == rhs.balls && lhs.type == rhs.type
    }
}
