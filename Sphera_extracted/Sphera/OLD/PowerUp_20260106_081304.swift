//
//  PowerUp.swift
//  BallSortPuzzle
//
//  Created on 2026-01-03.
//

import SwiftUI

// MARK: - PowerUp Type

enum PowerUpType: String, CaseIterable, Codable {
    case shuffle        // Rimescola le palline nei tubi
    case colorBomb      // Rimuove tutte le palline di un colore
    case undoAll        // Torna all'inizio del livello
    case freezeTimer    // Ferma il timer per 30 secondi
    case magicWand      // Completa automaticamente un tubo

    var displayName: String {
        switch self {
        case .shuffle: return L10n.powerUpShuffle
        case .colorBomb: return L10n.powerUpColorBomb
        case .undoAll: return L10n.powerUpUndoAll
        case .freezeTimer: return L10n.powerUpFreezeTimer
        case .magicWand: return L10n.powerUpMagicWand
        }
    }

    var description: String {
        switch self {
        case .shuffle: return L10n.powerUpShuffleDesc
        case .colorBomb: return L10n.powerUpColorBombDesc
        case .undoAll: return L10n.powerUpUndoAllDesc
        case .freezeTimer: return L10n.powerUpFreezeTimerDesc
        case .magicWand: return L10n.powerUpMagicWandDesc
        }
    }

    var icon: String {
        switch self {
        case .shuffle: return "shuffle"
        case .colorBomb: return "flame.fill"
        case .undoAll: return "arrow.uturn.backward.circle.fill"
        case .freezeTimer: return "snowflake"
        case .magicWand: return "wand.and.stars"
        }
    }

    var color: Color {
        switch self {
        case .shuffle: return Color(hex: "F97316") // Arancione
        case .colorBomb: return Color(hex: "EF4444") // Rosso
        case .undoAll: return Color(hex: "8B5CF6") // Viola
        case .freezeTimer: return Color(hex: "06B6D4") // Ciano
        case .magicWand: return Color(hex: "F59E0B") // Oro
        }
    }

    var cost: Int {
        switch self {
        case .shuffle: return 50
        case .colorBomb: return 100
        case .undoAll: return 30
        case .freezeTimer: return 75
        case .magicWand: return 150
        }
    }
}

// MARK: - PowerUp Model

struct PowerUp: Identifiable, Codable {
    let id: UUID
    let type: PowerUpType
    var quantity: Int

    init(type: PowerUpType, quantity: Int = 0) {
        self.id = UUID()
        self.type = type
        self.quantity = quantity
    }
}

// MARK: - PowerUp Inventory

class PowerUpInventory: ObservableObject, Codable {
    @Published var powerUps: [PowerUpType: Int]
    @Published var coins: Int

    enum CodingKeys: String, CodingKey {
        case powerUps, coins
    }

    init() {
        self.powerUps = [:]
        self.coins = 100 // Monete iniziali

        // Inizializza con 0 per ogni tipo
        for type in PowerUpType.allCases {
            powerUps[type] = 0
        }
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decodifica dizionario come [String: Int] e converti
        let rawPowerUps = try container.decode([String: Int].self, forKey: .powerUps)
        var converted: [PowerUpType: Int] = [:]
        for (key, value) in rawPowerUps {
            if let type = PowerUpType(rawValue: key) {
                converted[type] = value
            }
        }
        self.powerUps = converted
        self.coins = try container.decode(Int.self, forKey: .coins)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        // Converti dizionario in [String: Int] per encoding
        var rawPowerUps: [String: Int] = [:]
        for (key, value) in powerUps {
            rawPowerUps[key.rawValue] = value
        }
        try container.encode(rawPowerUps, forKey: .powerUps)
        try container.encode(coins, forKey: .coins)
    }

    // MARK: - Methods

    func getQuantity(for type: PowerUpType) -> Int {
        return powerUps[type] ?? 0
    }

    func canUse(_ type: PowerUpType) -> Bool {
        return getQuantity(for: type) > 0
    }

    func use(_ type: PowerUpType) -> Bool {
        guard canUse(type) else { return false }
        powerUps[type] = (powerUps[type] ?? 0) - 1
        return true
    }

    func canBuy(_ type: PowerUpType) -> Bool {
        return coins >= type.cost
    }

    func buy(_ type: PowerUpType) -> Bool {
        guard canBuy(type) else { return false }
        coins -= type.cost
        powerUps[type] = (powerUps[type] ?? 0) + 1
        return true
    }

    func addCoins(_ amount: Int) {
        coins += amount
    }

    func addPowerUp(_ type: PowerUpType, quantity: Int = 1) {
        powerUps[type] = (powerUps[type] ?? 0) + quantity
    }
}

// MARK: - L10n Extensions for PowerUps

extension L10n {
    // Power-up names
    static var powerUpShuffle: String {
        current == .italian ? "Mescola" : "Shuffle"
    }
    static var powerUpColorBomb: String {
        current == .italian ? "Bomba Colore" : "Color Bomb"
    }
    static var powerUpUndoAll: String {
        current == .italian ? "Ricomincia" : "Restart"
    }
    static var powerUpFreezeTimer: String {
        current == .italian ? "Gelo" : "Freeze"
    }
    static var powerUpMagicWand: String {
        current == .italian ? "Bacchetta" : "Magic Wand"
    }

    // Power-up descriptions
    static var powerUpShuffleDesc: String {
        current == .italian ? "Rimescola le palline nei tubi" : "Shuffle balls in tubes"
    }
    static var powerUpColorBombDesc: String {
        current == .italian ? "Rimuovi tutte le palline di un colore" : "Remove all balls of one color"
    }
    static var powerUpUndoAllDesc: String {
        current == .italian ? "Torna all'inizio del livello" : "Return to level start"
    }
    static var powerUpFreezeTimerDesc: String {
        current == .italian ? "Ferma il timer per 30 secondi" : "Stop timer for 30 seconds"
    }
    static var powerUpMagicWandDesc: String {
        current == .italian ? "Completa automaticamente un tubo" : "Auto-complete one tube"
    }

    // UI
    static var powerUps: String {
        current == .italian ? "Power-Up" : "Power-Ups"
    }
    static var coins: String {
        current == .italian ? "Monete" : "Coins"
    }
    static var buy: String {
        current == .italian ? "Compra" : "Buy"
    }
    static var use: String {
        current == .italian ? "Usa" : "Use"
    }
    static var notEnoughCoins: String {
        current == .italian ? "Monete insufficienti!" : "Not enough coins!"
    }
    static var selectColor: String {
        current == .italian ? "Seleziona un colore" : "Select a color"
    }
}
