//
//  GameViewModel.swift
//  BallSortPuzzle
//
//  Created on 2026-01-02.
//

import SwiftUI

@MainActor
class GameViewModel: ObservableObject {
    @Published var gameState: GameState
    @Published var showWinAlert: Bool = false
    @Published var animatingBallFrom: Int?
    @Published var animatingBallTo: Int?

    private let userDefaultsKey = "BallSortPuzzle_CurrentLevel"

    init() {
        let savedLevel = UserDefaults.standard.integer(forKey: userDefaultsKey)
        let startLevel = savedLevel > 0 ? savedLevel : 1
        self.gameState = GameState(currentLevel: startLevel)
        startNewLevel(startLevel)
    }

    var currentLevel: Int {
        gameState.currentLevel
    }

    var moves: Int {
        gameState.moves
    }

    var selectedTubeIndex: Int? {
        gameState.selectedTubeIndex
    }

    func startNewLevel(_ level: Int) {
        let levelConfig = Level(number: level)
        gameState = GameState(
            tubes: levelConfig.generateTubes(),
            moves: 0,
            currentLevel: level
        )
        showWinAlert = false
        saveProgress()
    }

    func restartLevel() {
        startNewLevel(gameState.currentLevel)
    }

    func nextLevel() {
        startNewLevel(gameState.currentLevel + 1)
    }

    func selectTube(at index: Int) {
        let result = gameState.selectTube(at: index)

        switch result {
        case .moved:
            // Suono di spostamento (placeholder per quando aggiungerai i suoni)
            playMoveSound()
        case .won:
            withAnimation(.easeInOut(duration: 0.5)) {
                showWinAlert = true
            }
            playWinSound()
        case .invalid:
            playErrorSound()
        default:
            break
        }
    }

    func addEmptyTube() {
        guard gameState.tubes.count < 12 else { return }
        gameState.tubes.append(Tube(capacity: 4))
    }

    // MARK: - Sound Effects (Placeholder)

    private func playMoveSound() {
        // TODO: Implementare suono spostamento
    }

    private func playWinSound() {
        // TODO: Implementare suono vittoria
    }

    private func playErrorSound() {
        // TODO: Implementare suono errore
    }

    // MARK: - Persistence

    private func saveProgress() {
        UserDefaults.standard.set(gameState.currentLevel, forKey: userDefaultsKey)
    }
}
