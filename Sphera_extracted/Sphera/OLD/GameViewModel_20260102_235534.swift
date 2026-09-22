//
//  GameViewModel.swift
//  BallSortPuzzle
//
//  Created on 2026-01-02.
//

import SwiftUI
import AudioToolbox

@MainActor
class GameViewModel: ObservableObject {
    @Published var gameState: GameState
    @Published var showWinAlert: Bool = false
    @Published var lastScore: Int = 0
    @Published var lastStars: Int = 0

    let settings = SettingsManager.shared

    private var currentLevelConfig: Level?

    private var userDefaultsKey: String {
        "BallSortPuzzle_CurrentLevel_\(settings.difficulty.rawValue)"
    }

    init() {
        self.gameState = GameState(currentLevel: 1)
        loadSavedLevel()
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

    var difficulty: Difficulty {
        settings.difficulty
    }

    func loadSavedLevel() {
        let savedLevel = UserDefaults.standard.integer(forKey: userDefaultsKey)
        let startLevel = savedLevel > 0 ? savedLevel : 1
        startNewLevel(startLevel)
    }

    func changeDifficulty(to newDifficulty: Difficulty) {
        settings.difficulty = newDifficulty
        loadSavedLevel()
    }

    func startNewLevel(_ level: Int) {
        let levelConfig = Level(number: level, difficulty: settings.difficulty)
        currentLevelConfig = levelConfig
        gameState = GameState(
            tubes: levelConfig.generateTubes(),
            moves: 0,
            currentLevel: level
        )
        showWinAlert = false
        lastScore = 0
        lastStars = 0
        saveProgress()
    }

    func restartLevel() {
        startNewLevel(gameState.currentLevel)
    }

    func nextLevel() {
        startNewLevel(gameState.currentLevel + 1)
    }

    func resetToFirstLevel() {
        startNewLevel(1)
    }

    func resetAllProgress() {
        settings.resetProgress()
        startNewLevel(1)
    }

    func selectTube(at index: Int) {
        let result = gameState.selectTube(at: index)

        switch result {
        case .moved:
            playMoveSound()
            playHaptic(.light)
        case .won:
            handleWin()
        case .invalid:
            playErrorSound()
            playHaptic(.medium)
        case .selected:
            playHaptic(.light)
        default:
            break
        }
    }

    func addEmptyTube() {
        guard gameState.tubes.count < 12 else { return }
        gameState.tubes.append(Tube(capacity: 4))
        playHaptic(.light)
    }

    private func handleWin() {
        // Calcola punteggio e stelle
        let optimalMoves = currentLevelConfig?.optimalMoves ?? (gameState.currentLevel * 4)
        lastStars = settings.calculateStars(moves: gameState.moves, optimalMoves: optimalMoves)
        lastScore = settings.addScore(moves: gameState.moves, level: gameState.currentLevel)

        settings.totalStars += lastStars
        settings.gamesCompleted += 1

        withAnimation(.easeInOut(duration: 0.5)) {
            showWinAlert = true
        }
        playWinSound()
        playHaptic(.success)
    }

    // MARK: - Sound Effects

    private func playMoveSound() {
        guard settings.soundEnabled else { return }
        AudioServicesPlaySystemSound(1104) // Tock sound
    }

    private func playWinSound() {
        guard settings.soundEnabled else { return }
        AudioServicesPlaySystemSound(1025) // Fanfare-like
    }

    private func playErrorSound() {
        guard settings.soundEnabled else { return }
        AudioServicesPlaySystemSound(1053) // Error sound
    }

    // MARK: - Haptics

    private func playHaptic(_ style: HapticStyle) {
        guard settings.vibrationEnabled else { return }

        switch style {
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        case .medium:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        case .success:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }

    private enum HapticStyle {
        case light, medium, success
    }

    // MARK: - Persistence

    private func saveProgress() {
        UserDefaults.standard.set(gameState.currentLevel, forKey: userDefaultsKey)
    }
}
