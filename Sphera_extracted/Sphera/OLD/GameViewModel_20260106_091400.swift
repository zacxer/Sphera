//
//  GameViewModel.swift
//  BallSortPuzzle
//
//  Created on 2026-01-02.
//

import SwiftUI
import AudioToolbox
import Combine

@MainActor
class GameViewModel: ObservableObject {
    @Published var gameState: GameState
    @Published var showWinAlert: Bool = false
    @Published var lastScore: Int = 0
    @Published var lastStars: Int = 0
    @Published var lastOptimalMoves: Int = 0

    // FASE 3: Dati livello corrente per forme
    @Published var currentLevelData: Level?

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

    // MARK: - Extra Tube System
    private var initialTubeCount: Int = 0
    let maxExtraTubes: Int = 1  // Massimo 1 tubo extra per livello

    // MARK: - Invalid Moves System (restart dopo X errori)
    @Published var invalidMovesCount: Int = 0
    @Published var showTooManyErrorsAlert: Bool = false

    /// Numero massimo di mosse invalide prima del restart automatico
    var maxInvalidMoves: Int {
        switch settings.difficulty {
        case .easy: return 10
        case .medium: return 5
        case .hard: return 3
        }
    }

    // MARK: - Timer System
    @Published var elapsedSeconds: Int = 0
    @Published var lastTimeBonus: Int = 0
    @Published var lastTimeBonusPercentage: Int = 0
    private var gameTimer: Timer?

    // MARK: - Power-ups System
    @Published var isTimerFrozen: Bool = false
    @Published var frozenTimeRemaining: Int = 0
    @Published var isSelectingColorBomb: Bool = false
    @Published var availableColorsForBomb: [BallColor] = []
    @Published var isSelectingMagicWand: Bool = false
    @Published var availableColorsForMagicWand: [BallColor] = []
    @Published var showPowerUpPanel: Bool = false
    @Published var lastCoinsEarned: Int = 0
    private var freezeTimer: Timer?

    // Stato iniziale del livello per UndoAll
    private var initialGameState: GameState?

    // MARK: - Ad Pause Observer
    private var adObserver: AnyCancellable?
    private var wasTimerRunningBeforeAd: Bool = false

    /// Tempo obiettivo in secondi per il livello corrente
    var targetTime: Int {
        let level = gameState.currentLevel
        switch settings.difficulty {
        case .easy: return 30 + (level * 5)      // 35s, 40s, 45s...
        case .medium: return 45 + (level * 8)   // 53s, 61s, 69s...
        case .hard: return 60 + (level * 10)    // 70s, 80s, 90s...
        }
    }

    /// Calcola la percentuale di bonus tempo
    var timeBonusPercentage: Int {
        let target = Double(targetTime)
        let elapsed = Double(elapsedSeconds)

        if elapsed <= target * 0.5 {
            return 100  // Sotto il 50% del tempo = +100%
        } else if elapsed <= target {
            return 50   // Sotto il tempo obiettivo = +50%
        } else if elapsed <= target * 1.5 {
            return 25   // Sotto il 150% = +25%
        } else {
            return 0    // Nessun bonus
        }
    }

    let settings = SettingsManager.shared

    private var currentLevelConfig: Level?
    private var hintTimer: Timer?

    private var userDefaultsKey: String {
        "BallSortPuzzle_CurrentLevel_\(settings.difficulty.rawValue)"
    }

    init() {
        self.gameState = GameState(currentLevel: 1)
        loadSavedLevel()
        setupAdObserver()
    }

    private func setupAdObserver() {
        adObserver = AdManager.shared.$isShowingFullscreenAd
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isShowingAd in
                guard let self = self else { return }
                if isShowingAd {
                    // Ad apparso - pausa timer
                    self.wasTimerRunningBeforeAd = self.gameTimer != nil
                    self.pauseGameTimer()
                } else {
                    // Ad chiuso - riprendi timer se era attivo
                    if self.wasTimerRunningBeforeAd && !self.showWinAlert {
                        self.resumeGameTimer()
                    }
                }
            }
    }

    private func pauseGameTimer() {
        gameTimer?.invalidate()
        gameTimer = nil
    }

    private func resumeGameTimer() {
        guard gameTimer == nil else { return }
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.elapsedSeconds += 1
            }
        }
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

    var canAddExtraTube: Bool {
        let extraTubesAdded = gameState.tubes.count - initialTubeCount
        let maxTotalTubes = 10  // Limite massimo assoluto
        return extraTubesAdded < maxExtraTubes && gameState.tubes.count < maxTotalTubes
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
        currentLevelData = levelConfig  // FASE 3: Per tutorial forme
        let tubes = levelConfig.generateTubes()
        initialTubeCount = tubes.count  // Salva numero tubi iniziali
        gameState = GameState(
            tubes: tubes,
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

        // Reset contatore errori
        invalidMovesCount = 0
        showTooManyErrorsAlert = false

        // Reset e avvia timer
        elapsedSeconds = 0
        lastTimeBonus = 0
        lastTimeBonusPercentage = 0
        lastCoinsEarned = 0
        isTimerFrozen = false
        frozenTimeRemaining = 0
        isSelectingColorBomb = false
        isSelectingMagicWand = false
        startTimer()

        // Salva stato iniziale per UndoAll
        initialGameState = GameState(
            tubes: gameState.tubes.map { tube in
                var copy = tube
                copy.balls = tube.balls
                return copy
            },
            moves: 0,
            currentLevel: level
        )

        saveProgress()
    }

    // MARK: - Timer Management

    private func startTimer() {
        stopTimer()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.elapsedSeconds += 1
            }
        }
    }

    private func stopTimer() {
        gameTimer?.invalidate()
        gameTimer = nil
    }

    /// Formatta i secondi in mm:ss
    var formattedTime: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    /// Formatta il tempo obiettivo in mm:ss
    var formattedTargetTime: String {
        let minutes = targetTime / 60
        let seconds = targetTime % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    func restartLevel() {
        startNewLevel(gameState.currentLevel)
    }

    func nextLevel() {
        // Prima nascondi l'overlay di vittoria
        showWinAlert = false

        // Salva il livello successivo prima di iniziarlo
        let nextLevelNumber = gameState.currentLevel + 1

        // Piccolo delay per assicurare che SwiftUI abbia processato la chiusura dell'overlay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            startNewLevel(nextLevelNumber)
        }
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
            }
            // NON contare come errore se si clicca su tubo vuoto/completo/bloccato
            // L'errore si conta solo quando si tenta uno spostamento invalido
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
            handleInvalidMove()
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

        // Gestisci risultato - controllo con delay per sicurezza
        if result == .won || gameState.isWon {
            if !showWinAlert {
                // Delay per assicurare che SwiftUI abbia aggiornato lo stato
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [self] in
                    if gameState.isWon && !showWinAlert {
                        handleWin()
                    }
                }
            }
        }
    }

    private func resetAnimation() {
        isAnimating = false
        animatingBall = nil
        animationFromIndex = nil
        animationToIndex = nil
    }

    func addEmptyTube() {
        guard canAddExtraTube else { return }
        gameState.tubes.append(Tube(capacity: 4))
        playHaptic(.light)
    }

    // MARK: - Invalid Moves Handling

    private func handleInvalidMove() {
        invalidMovesCount += 1

        // Controlla se ha raggiunto il limite
        if invalidMovesCount >= maxInvalidMoves {
            showTooManyErrorsAlert = true
        }
    }

    /// Chiamato quando l'utente conferma il restart dopo troppi errori
    func confirmRestartAfterErrors() {
        showTooManyErrorsAlert = false
        restartLevel()
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
        // Ferma il timer
        stopTimer()
        freezeTimer?.invalidate()
        freezeTimer = nil

        // Calcola punteggio base e stelle
        let optimalMoves = currentLevelConfig?.optimalMoves ?? (gameState.currentLevel * 4)
        lastOptimalMoves = optimalMoves
        lastStars = settings.calculateStars(moves: gameState.moves, optimalMoves: optimalMoves)

        // Calcola punteggio base
        let baseScore = settings.addScore(moves: gameState.moves, level: gameState.currentLevel)

        // Calcola bonus tempo
        lastTimeBonusPercentage = timeBonusPercentage
        lastTimeBonus = (baseScore * lastTimeBonusPercentage) / 100

        // Punteggio totale = base + bonus tempo
        lastScore = baseScore + lastTimeBonus

        // Calcola e assegna monete guadagnate
        let hasTimeBonus = lastTimeBonusPercentage > 0
        lastCoinsEarned = settings.calculateCoinsEarned(
            level: gameState.currentLevel,
            stars: lastStars,
            timeBonus: hasTimeBonus
        )
        settings.addCoins(lastCoinsEarned)

        settings.totalStars += lastStars
        settings.gamesCompleted += 1

        withAnimation(.easeInOut(duration: 0.5)) {
            showWinAlert = true
        }
        playWinSound()
        playHaptic(.success)

        // Mostra interstitial ogni 3 livelli
        AdManager.shared.showInterstitialIfReady()

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
        // Usa sfx_button.wav per lo spostamento delle palle
        AudioManager.shared.playBallMoveSound()
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

    // MARK: - Power-ups

    func canUsePowerUp(_ type: PowerUpType) -> Bool {
        return settings.canUsePowerUp(type)
    }

    func usePowerUp(_ type: PowerUpType) {
        // Per colorBomb e magicWand: NON scalare subito, aspetta selezione colore
        // Altrimenti se annulla perde le monete
        switch type {
        case .colorBomb:
            guard settings.canUsePowerUp(.colorBomb) else {
                playErrorSound()
                return
            }
            startColorBombSelection()
            playHaptic(.medium)

        case .magicWand:
            guard settings.canUsePowerUp(.magicWand) else {
                playErrorSound()
                return
            }
            startMagicWandSelection()
            playHaptic(.medium)

        default:
            // Per gli altri power-up, scala subito
            guard settings.usePowerUp(type) else {
                playErrorSound()
                return
            }

            switch type {
            case .shuffle:
                executeShuffle()
            case .undoAll:
                executeUndoAll()
            case .freezeTimer:
                executeFreezeTimer()
            default:
                break
            }

            playHaptic(.medium)
        }
    }

    // MARK: - Shuffle Power-up

    private func executeShuffle() {
        // Raccogli tutte le palline
        var allBalls: [Ball] = []
        for tube in gameState.tubes {
            allBalls.append(contentsOf: tube.balls)
        }

        // Mescola
        allBalls.shuffle()

        // Ridistribuisci nei tubi (non nei tubi speciali bloccati)
        var ballIndex = 0
        for i in 0..<gameState.tubes.count {
            // Salta tubi bloccati
            if gameState.tubes[i].isTubeLocked { continue }

            gameState.tubes[i].balls.removeAll()

            // Riempi fino alla capacità o fino a esaurimento palline
            let capacity = gameState.tubes[i].capacity
            while gameState.tubes[i].balls.count < capacity && ballIndex < allBalls.count {
                gameState.tubes[i].balls.append(allBalls[ballIndex])
                ballIndex += 1
            }
        }

        // Pulisci selezione
        gameState.selectedTubeIndex = nil
        clearHint()

        playMoveSound()
    }

    // MARK: - Color Bomb Power-up

    private func startColorBombSelection() {
        // Trova tutti i colori disponibili nel gioco
        var colors: Set<BallColor> = []
        for tube in gameState.tubes {
            for ball in tube.balls {
                colors.insert(ball.ballColor)
            }
        }
        availableColorsForBomb = Array(colors).sorted { $0.rawValue < $1.rawValue }
        isSelectingColorBomb = true
    }

    func selectColorForBomb(_ color: BallColor) {
        isSelectingColorBomb = false

        // ORA scala le monete/power-up (dopo la selezione)
        guard settings.usePowerUp(.colorBomb) else {
            playErrorSound()
            return
        }

        // Rimuovi tutte le palline di quel colore
        for i in 0..<gameState.tubes.count {
            gameState.tubes[i].balls.removeAll { $0.ballColor == color }
        }

        playMoveSound()
        clearHint()

        // Controlla vittoria
        if gameState.isWon && !showWinAlert {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
                handleWin()
            }
        }
    }

    func cancelColorBombSelection() {
        isSelectingColorBomb = false
        // NON restituire niente - non è stato scalato nulla
    }

    // MARK: - Undo All Power-up

    private func executeUndoAll() {
        guard let initial = initialGameState else {
            restartLevel()
            return
        }

        // Ripristina stato iniziale
        gameState.tubes = initial.tubes
        gameState.moves = 0
        gameState.moveHistory.removeAll()
        gameState.selectedTubeIndex = nil

        // Reset contatori
        invalidMovesCount = 0
        elapsedSeconds = 0

        clearHint()
        playMoveSound()
    }

    // MARK: - Freeze Timer Power-up

    private func executeFreezeTimer() {
        isTimerFrozen = true
        frozenTimeRemaining = 30 // 30 secondi

        // Ferma timer principale
        stopTimer()

        // Avvia countdown freeze
        freezeTimer?.invalidate()
        freezeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                self.frozenTimeRemaining -= 1
                if self.frozenTimeRemaining <= 0 {
                    self.endFreezeTimer()
                }
            }
        }
    }

    private func endFreezeTimer() {
        freezeTimer?.invalidate()
        freezeTimer = nil
        isTimerFrozen = false
        frozenTimeRemaining = 0

        // Riavvia timer normale (solo se il gioco non è finito)
        if !showWinAlert {
            startTimer()
        }
    }

    // MARK: - Magic Wand Power-up

    private func startMagicWandSelection() {
        // Trova tutti i colori disponibili nel gioco (non già completi)
        var colors: Set<BallColor> = []
        for tube in gameState.tubes {
            if tube.isComplete { continue }
            for ball in tube.balls {
                colors.insert(ball.ballColor)
            }
        }

        if colors.isEmpty {
            playErrorSound()
            // NON incrementare - non abbiamo scalato niente
            return
        }

        availableColorsForMagicWand = Array(colors).sorted { $0.rawValue < $1.rawValue }
        isSelectingMagicWand = true
    }

    func selectColorForMagicWand(_ color: BallColor) {
        isSelectingMagicWand = false

        // Trova un tubo vuoto per raccogliere le palline
        var targetIndex: Int? = nil

        // Prima cerca un tubo vuoto
        for (index, tube) in gameState.tubes.enumerated() {
            if tube.isEmpty && !tube.isTubeLocked {
                targetIndex = index
                break
            }
        }

        // Se non c'è un tubo vuoto, cerca un tubo con SOLO palline di quel colore
        if targetIndex == nil {
            for (index, tube) in gameState.tubes.enumerated() {
                if tube.isTubeLocked || tube.isComplete { continue }
                if !tube.isEmpty && tube.balls.allSatisfy({ $0.ballColor == color }) {
                    targetIndex = index
                    break
                }
            }
        }

        guard let targetIdx = targetIndex else {
            playErrorSound()
            return
        }

        // ORA scala le monete (dopo la selezione e verifica)
        guard settings.usePowerUp(.magicWand) else {
            playErrorSound()
            return
        }

        // MAGIA: Raccogli TUTTE le palline del colore da TUTTI i tubi
        // (ignora le regole - prende anche dal fondo!)
        var collectedBalls: [Ball] = []

        for i in 0..<gameState.tubes.count {
            if i == targetIdx || gameState.tubes[i].isTubeLocked { continue }

            // Prendi TUTTE le palline del colore target (non solo dalla cima)
            let ballsToKeep = gameState.tubes[i].balls.filter { $0.ballColor != color }
            let ballsToCollect = gameState.tubes[i].balls.filter { $0.ballColor == color }
            collectedBalls.append(contentsOf: ballsToCollect)
            gameState.tubes[i].balls = ballsToKeep
        }

        // Metti le palline raccolte nel tubo target (fino alla capacità)
        let capacity = gameState.tubes[targetIdx].capacity
        for ball in collectedBalls {
            if gameState.tubes[targetIdx].balls.count < capacity {
                gameState.tubes[targetIdx].balls.append(ball)
            }
        }

        playMoveSound()
        clearHint()

        // Controlla vittoria
        if gameState.isWon && !showWinAlert {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
                handleWin()
            }
        }
    }

    func cancelMagicWandSelection() {
        isSelectingMagicWand = false
        // NON restituire niente - non è stato scalato nulla
    }
}
