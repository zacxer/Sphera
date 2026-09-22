//
//  SettingsManager.swift
//  BallSortPuzzle
//
//  Created on 2026-01-02.
//

import SwiftUI

enum Difficulty: String, CaseIterable, Codable {
    case easy = "Facile"
    case medium = "Medio"
    case hard = "Difficile"

    var icon: String {
        switch self {
        case .easy: return "leaf.fill"
        case .medium: return "flame.fill"
        case .hard: return "bolt.fill"
        }
    }

    var color: Color {
        switch self {
        case .easy: return .ballGreen
        case .medium: return .ballYellow
        case .hard: return .ballRed
        }
    }

    var description: String {
        switch self {
        case .easy: return "3-4 colori, ideale per iniziare"
        case .medium: return "4-6 colori, sfida bilanciata"
        case .hard: return "5-8 colori, per esperti"
        }
    }
}

@MainActor
class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    @AppStorage("soundEnabled") var soundEnabled: Bool = true
    @AppStorage("vibrationEnabled") var vibrationEnabled: Bool = true
    @AppStorage("difficulty") private var difficultyRaw: String = Difficulty.medium.rawValue
    @AppStorage("highScore") var highScore: Int = 0
    @AppStorage("totalStars") var totalStars: Int = 0
    @AppStorage("gamesCompleted") var gamesCompleted: Int = 0

    var difficulty: Difficulty {
        get { Difficulty(rawValue: difficultyRaw) ?? .medium }
        set {
            difficultyRaw = newValue.rawValue
            objectWillChange.send()
        }
    }

    private init() {}

    func resetProgress() {
        UserDefaults.standard.set(1, forKey: "BallSortPuzzle_CurrentLevel_easy")
        UserDefaults.standard.set(1, forKey: "BallSortPuzzle_CurrentLevel_medium")
        UserDefaults.standard.set(1, forKey: "BallSortPuzzle_CurrentLevel_hard")
        highScore = 0
        totalStars = 0
        gamesCompleted = 0
    }

    func addScore(moves: Int, level: Int) -> Int {
        // Calcola punteggio: meno mosse = più punti
        let baseScore = level * 100
        let moveBonus = max(0, (level * 10 - moves) * 5)
        let difficultyMultiplier: Double = {
            switch difficulty {
            case .easy: return 1.0
            case .medium: return 1.5
            case .hard: return 2.0
            }
        }()

        let score = Int(Double(baseScore + moveBonus) * difficultyMultiplier)

        if score > highScore {
            highScore = score
        }

        return score
    }

    func calculateStars(moves: Int, optimalMoves: Int) -> Int {
        let ratio = Double(moves) / Double(optimalMoves)
        if ratio <= 1.2 {
            return 3
        } else if ratio <= 1.8 {
            return 2
        } else {
            return 1
        }
    }
}
