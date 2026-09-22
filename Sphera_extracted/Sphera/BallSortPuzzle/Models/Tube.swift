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
    case frozen      // Pallina in cima congelata, si scongela dopo X mosse
    case tall        // Capacità 6 invece di 4
    case locked      // Bloccato finché non si sblocca
    case portalA     // Portale A (collegato a B)
    case portalB     // Portale B (collegato a A)

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
        }
    }

    var icon: String {
        switch self {
        case .normal: return "cylinder"
        case .frozen: return "snowflake"
        case .tall: return "arrow.up"
        case .locked: return "lock.fill"
        case .portalA, .portalB: return "arrow.triangle.2.circlepath"
        }
    }

    var accentColor: Color {
        switch self {
        case .normal: return .clear
        case .frozen: return Color(hex: "00D4FF")
        case .tall: return Color(hex: "FFD700")
        case .locked: return Color(hex: "FF6B6B")
        case .portalA: return Color(hex: "FFD700") // Oro
        case .portalB: return Color(hex: "FFD700") // Oro
        }
    }
}

// MARK: - PortalColor (per distinguere coppie di portali) - Tutti colori ORO brillanti

enum PortalColor: String, CaseIterable, Codable {
    case purple  // Manteniamo il nome per compatibilità, ma ora è oro
    case orange
    case cyan

    var color: Color {
        switch self {
        case .purple: return Color(hex: "FFD700") // Oro brillante
        case .orange: return Color(hex: "FFC107") // Oro ambra
        case .cyan: return Color(hex: "FFDF00")   // Oro giallo
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

    /// Tubo completo = tutti pezzi IDENTICI (stesso colore E stessa forma) - FASE 3
    var isComplete: Bool {
        guard balls.count == capacity else { return false }
        guard let first = balls.first else { return false }
        // Tutti devono essere identici al primo (colore + forma)
        return balls.allSatisfy { $0.isIdenticalTo(first) }
    }

    /// Conta pezzi consecutivi in cima che sono IDENTICI (stesso colore E forma)
    var consecutiveTopBallsCount: Int {
        guard let topBall = topBall else { return 0 }
        var count = 0
        for ball in balls.reversed() {
            if ball.isIdenticalTo(topBall) {
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

    /// Può accettare pezzo considerando tipo speciale - FASE 3: stesso COLORE o stessa FORMA
    func canReceiveBall(_ ball: Ball) -> Bool {
        // Locked tube non può ricevere
        if isTubeLocked {
            return false
        }

        // Normal rules
        if isEmpty { return true }
        if isFull { return false }

        // FASE 3: può impilare se stesso COLORE o stessa FORMA
        guard let top = topBall else { return true }
        return ball.canStackWith(top)
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

    static func == (lhs: Tube, rhs: Tube) -> Bool {
        lhs.id == rhs.id && lhs.balls == rhs.balls && lhs.type == rhs.type
    }
}
