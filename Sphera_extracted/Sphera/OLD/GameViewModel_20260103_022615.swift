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

    // MARK: - Undo System
    @Published var undoRemaining: Int = 5
    let maxFreeUndo: Int = 5

    // MARK: - Hint System
    @Published var hintRemaining: Int = 2
    @Published var hintSourceIndex: Int? = nil
    @Published var hintDestIndex: Int? = nil
    @Published var isShowingHint: Bool = false
    let maxFreeHints: Int = 2

    // MARK: - Animation System
    @Published var isAnimating: Bool = false
    @Published var animatingBall: Ball? = nil
    @Published var animationFromIndex: Int? = nil
    @Published var animationToIndex: Int? = nil

    let settings = SettingsManager.shared

    private var currentLevelConfig: Level?
    private var hintTimer: Timer?

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

    var canUndo: Bool {
        gameState.canUndo && undoRemaining > 0
    }

    var canShowHint: Bool {
        hintRemaining > 0 && !isShowingHint
    }

    // MARK: - Level Management

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

        // Reset undo e hint per il nuovo livello
        undoRemaining = maxFreeUndo
        hintRemaining = maxFreeHints
        clearHint()

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

    // MARK: - Tube Selection & Movement

    func selectTube(at index: Int) {
        // Se animazione in corso, ignora
        guard !isAnimating else { return }

        // Controllo fallback: se il gioco è vinto ma l'alert non è stato mostrato
        // (risolve bug di timing con animazioni SwiftUI)
        if gameState.isWon && !showWinAlert {
            handleWin()
            return
        }

        // Pulisci hint quando l'utente interagisce
        if isShowingHint {
            clearHint()
        }

        // Se non c'è selezione, seleziona
        guard let selectedIndex = gameState.selectedTubeIndex else {
            let result = gameState.selectTube(at: index)
            if result == .selected {
                playSelectSound() // Suono selezione
                playHaptic(.medium)
            } else if result == .invalid {
                playErrorSound()
                playHaptic(.heavy)
            }
            return
        }

        // Se clicco sullo stesso tubo, deseleziona
        if selectedIndex == index {
            gameState.selectedTubeIndex = nil
            playHaptic(.light) // Vibrazione leggera per deselection
            return
        }

        // Verifica se la mossa è valida PRIMA di eseguirla
        guard let ball = gameState.tubes[selectedIndex].topBall,
              gameState.tubes[index].canReceiveBall(ball) else {
            gameState.selectedTubeIndex = nil
            playErrorSound()
            playHaptic(.heavy) // Vibrazione forte per errore
            return
        }

        // Avvia animazione
        startMoveAnimation(from: selectedIndex, to: index, ball: ball)
    }

    // MARK: - Animation

    private func startMoveAnimation(from sourceIndex: Int, to destIndex: Int, ball: Ball) {
        animatingBall = ball
        animationFromIndex = sourceIndex
        animationToIndex = destIndex
        isAnimating = true

        playMoveSound()
        playHaptic(.medium) // Vibrazione per spostamento

        // Dopo l'animazione, esegui la mossa reale (usa Task per sicurezza MainActor)
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 350_000_000) // 0.35 secondi
            self.completeMoveAnimation()
        }
    }

    private func completeMoveAnimation() {
        guard let fromIndex = animationFromIndex,
              let toIndex = animationToIndex else {
            resetAnimation()
            return
        }

        // Esegui la mossa reale
        let result = gameState.moveBall(from: fromIndex, to: toIndex)

        // Reset animazione
        resetAnimation()

        // Gestisci risultato
        if result == .won {
            handleWin()
        }
    }

    private func resetAnimation() {
        isAnimating = false
        animatingBall = nil
        animationFromIndex = nil
        animationToIndex = nil
    }

    func addEmptyTube() {
        guard gameState.tubes.count < 12 else { return }
        gameState.tubes.append(Tube(capacity: 4))
        playHaptic(.light)
    }

    // MARK: - Undo System

    func undo() {
        guard canUndo else {
            playErrorSound()
            return
        }

        if gameState.undoLastMove() {
            undoRemaining -= 1
            playMoveSound()
            playHaptic(.light)
        }
    }

    func addExtraUndo(count: Int = 3) {
        // Chiamato dopo aver visto una rewarded ad
        undoRemaining += count
    }

    // MARK: - Hint System

    func showHint() {
        guard canShowHint else {
            playErrorSound()
            return
        }

        if let hint = findBestMove() {
            hintSourceIndex = hint.from
            hintDestIndex = hint.to
            isShowingHint = true
            hintRemaining -= 1
            playHaptic(.light)

            // Auto-nascondi dopo 3 secondi
            hintTimer?.invalidate()
            hintTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
                Task { @MainActor in
                    self?.clearHint()
                }
            }
        } else {
            // Nessuna mossa trovata
            playErrorSound()
        }
    }

    func clearHint() {
        hintTimer?.invalidate()
        hintTimer = nil
        isShowingHint = false
        hintSourceIndex = nil
        hintDestIndex = nil
    }

    func addExtraHints(count: Int = 2) {
        // Chiamato dopo aver visto una rewarded ad
        hintRemaining += count
    }

    // Algoritmo per trovare la migliore mossa suggerita
    private func findBestMove() -> (from: Int, to: Int)? {
        let tubes = gameState.tubes

        // Priorità 1: Trova pallina che può essere messa su pallina stesso colore
        for sourceIndex in 0..<tubes.count {
            guard !tubes[sourceIndex].isEmpty,
                  !tubes[sourceIndex].isComplete,
                  let topBall = tubes[sourceIndex].topBall else { continue }

            for destIndex in 0..<tubes.count {
                guard sourceIndex != destIndex,
                      !tubes[destIndex].isFull,
                      !tubes[destIndex].isEmpty else { continue }

                if tubes[destIndex].canReceiveBall(topBall) {
                    // Preferisci spostare dove ci sono già palline dello stesso colore
                    if tubes[destIndex].topBall?.ballColor == topBall.ballColor {
                        return (sourceIndex, destIndex)
                    }
                }
            }
        }

        // Priorità 2: Sposta su tubo vuoto (solo se necessario)
        for sourceIndex in 0..<tubes.count {
            guard !tubes[sourceIndex].isEmpty,
                  !tubes[sourceIndex].isComplete,
                  tubes[sourceIndex].topBall != nil else { continue }

            // Non spostare se il tubo ha già tutte palline dello stesso colore
            if tubes[sourceIndex].consecutiveTopBallsCount == tubes[sourceIndex].balls.count {
                continue
            }

            for destIndex in 0..<tubes.count {
                guard sourceIndex != destIndex,
                      tubes[destIndex].isEmpty else { continue }

                return (sourceIndex, destIndex)
            }
        }

        return nil
    }

    // MARK: - Win Handling

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

        // Controlla se mostrare Rate App popup
        RateAppManager.shared.checkAndRequestReview()
    }

    // MARK: - Sound Effects

    private func playSelectSound() {
        guard settings.soundEnabled else { return }
        // Suono leggero per selezione tubo
        AudioServicesPlaySystemSound(1104) // Tock
    }

    private func playMoveSound() {
        guard settings.soundEnabled else { return }
        // Suono forte per spostamento palla - 5 riproduzioni rapide
        for i in 0..<5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.02) {
                AudioServicesPlaySystemSound(1306) // Keyboard click piu' forte
            }
        }
    }

    private func playWinSound() {
        guard settings.soundEnabled else { return }
        // Suono vittoria forte
        AudioServicesPlaySystemSound(1025)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            AudioServicesPlaySystemSound(1025)
        }
    }

    private func playErrorSound() {
        guard settings.soundEnabled else { return }
        AudioServicesPlaySystemSound(1053) // Error sound
    }

    // MARK: - Haptics

    // Generator persistenti per migliori performance
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()

    private func playHaptic(_ style: HapticStyle) {
        guard settings.vibrationEnabled else { return }

        switch style {
        case .light:
            lightGenerator.prepare()
            lightGenerator.impactOccurred()
        case .medium:
            mediumGenerator.prepare()
            mediumGenerator.impactOccurred()
        case .heavy:
            heavyGenerator.prepare()
            heavyGenerator.impactOccurred()
        case .success:
            notificationGenerator.prepare()
            notificationGenerator.notificationOccurred(.success)
        }
    }

    private enum HapticStyle {
        case light, medium, heavy, success
    }

    // MARK: - Persistence

    private func saveProgress() {
        UserDefaults.standard.set(gameState.currentLevel, forKey: userDefaultsKey)
    }
}
