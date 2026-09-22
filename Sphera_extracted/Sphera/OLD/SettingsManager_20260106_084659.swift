//
//  SettingsManager.swift
//  BallSortPuzzle
//
//  Created on 2026-01-02.
//

import SwiftUI

// MARK: - Language Enum

enum AppLanguage: String, CaseIterable {
    case italian = "IT"
    case english = "EN"

    var flag: String {
        switch self {
        case .italian: return "🇮🇹"
        case .english: return "🇬🇧"
        }
    }
}

// MARK: - Localization Manager

struct L10n {
    // Legge direttamente da UserDefaults per evitare problemi di concurrency
    static var current: AppLanguage {
        let raw = UserDefaults.standard.string(forKey: "language") ?? "IT"
        return AppLanguage(rawValue: raw) ?? .italian
    }
    static var ballSort: String { current == .italian ? "BALL SORT" : "BALL SORT" }
    static var puzzle: String { current == .italian ? "PUZZLE" : "PUZZLE" }
    static var play: String { current == .italian ? "GIOCA" : "PLAY" }
    static var level: String { current == .italian ? "Livello" : "Level" }
    static var sortBallsByColor: String { current == .italian ? "Ordina le palline per colore!" : "Sort the balls by color!" }

    // Difficulty
    static var easy: String { current == .italian ? "Facile" : "Easy" }
    static var medium: String { current == .italian ? "Medio" : "Medium" }
    static var hard: String { current == .italian ? "Difficile" : "Hard" }
    static var easyDesc: String { current == .italian ? "3-4 colori, ideale per iniziare" : "3-4 colors, ideal for beginners" }
    static var mediumDesc: String { current == .italian ? "4-6 colori, sfida bilanciata" : "4-6 colors, balanced challenge" }
    static var hardDesc: String { current == .italian ? "5-8 colori, per esperti" : "5-8 colors, for experts" }
    static var difficulty: String { current == .italian ? "Difficoltà" : "Difficulty" }

    // Game
    static var moves: String { current == .italian ? "mosse" : "moves" }
    static var undo: String { current == .italian ? "Annulla" : "Undo" }
    static var hint: String { current == .italian ? "Suggerisci" : "Hint" }
    static var extraTube: String { current == .italian ? "Tubo +1" : "Tube +1" }

    // Win
    static var fantastic: String { current == .italian ? "FANTASTICO!" : "FANTASTIC!" }
    static var levelCompleted: String { current == .italian ? "Livello %d completato" : "Level %d completed" }
    static var time: String { current == .italian ? "Tempo" : "Time" }
    static var movesLabel: String { current == .italian ? "Mosse" : "Moves" }
    static var yourMoves: String { current == .italian ? "Le tue mosse" : "Your moves" }
    static var minMoves: String { current == .italian ? "Obiettivo" : "Target" }
    static var timeBonus: String { current == .italian ? "Bonus Tempo" : "Time Bonus" }
    static var points: String { current == .italian ? "punti" : "points" }
    static var totalScore: String { current == .italian ? "Punteggio Totale" : "Total Score" }
    static var nextLevel: String { current == .italian ? "Prossimo Livello" : "Next Level" }

    // Errors
    static var tooManyErrors: String { current == .italian ? "Troppi Errori!" : "Too Many Errors!" }
    static var youMadeErrors: String { current == .italian ? "Hai fatto %d mosse sbagliate" : "You made %d wrong moves" }
    static var errorLimit: String { current == .italian ? "Limite: %d errori" : "Limit: %d errors" }
    static var dontGiveUp: String { current == .italian ? "Non mollare! Riprova con calma" : "Don't give up! Try again calmly" }
    static var restart: String { current == .italian ? "Ricomincia" : "Restart" }

    // Settings
    static var settings: String { current == .italian ? "Impostazioni" : "Settings" }
    static var audio: String { current == .italian ? "Audio" : "Audio" }
    static var sounds: String { current == .italian ? "Suoni" : "Sounds" }
    static var music: String { current == .italian ? "Musica" : "Music" }
    static var vibration: String { current == .italian ? "Vibrazione" : "Vibration" }
    static var game: String { current == .italian ? "Gioco" : "Game" }
    static var restartFromLevel1: String { current == .italian ? "Ricomincia dal Livello 1" : "Restart from Level 1" }
    static var keepsStats: String { current == .italian ? "Mantiene le statistiche" : "Keeps statistics" }
    static var resetAll: String { current == .italian ? "Resetta Tutto" : "Reset All" }
    static var deleteAllProgress: String { current == .italian ? "Cancella tutti i progressi" : "Delete all progress" }
    static var info: String { current == .italian ? "Info" : "Info" }
    static var version: String { current == .italian ? "Versione" : "Version" }
    static var done: String { current == .italian ? "Fatto" : "Done" }
    static var cancel: String { current == .italian ? "Annulla" : "Cancel" }
    static var reset: String { current == .italian ? "Resetta" : "Reset" }
    static var resetAllQuestion: String { current == .italian ? "Resetta Tutto?" : "Reset All?" }
    static var resetWarning: String { current == .italian ? "Tutti i progressi e le statistiche verranno cancellati. Questa azione non può essere annullata." : "All progress and statistics will be deleted. This action cannot be undone." }

    // Stats
    static var statistics: String { current == .italian ? "Statistiche" : "Statistics" }
    static var stars: String { current == .italian ? "Stelle" : "Stars" }
    static var record: String { current == .italian ? "Record" : "Record" }
    static var completed: String { current == .italian ? "Completati" : "Completed" }

    // Shop - Actions
    static var shopActions: String { current == .italian ? "Azioni" : "Actions" }
    static var undoDesc: String { current == .italian ? "Annulla l'ultima mossa" : "Undo last move" }
    static var hintDesc: String { current == .italian ? "Mostra la prossima mossa" : "Show next move" }
    static var extraTubeDesc: String { current == .italian ? "Aggiungi un tubo vuoto" : "Add an empty tube" }

    // FASE 3: Shapes Tutorial
    static var shapesTutorialTitle: String { current == .italian ? "Nuove Forme!" : "New Shapes!" }
    static var shapesTutorialSubtitle: String { current == .italian ? "Ora ci sono diverse forme oltre alle palline!" : "Now there are different shapes besides balls!" }
    static var shapesTutorialRule1: String { current == .italian ? "Puoi impilare pezzi con stesso COLORE o stessa FORMA" : "You can stack pieces with same COLOR or same SHAPE" }
    static var shapesTutorialRule2: String { current == .italian ? "Per completare un tubo servono 4 pezzi IDENTICI (stesso colore E forma)" : "To complete a tube you need 4 IDENTICAL pieces (same color AND shape)" }
    static var shapesTutorialExample: String { current == .italian ? "Esempi:" : "Examples:" }
    static var shapesTutorialSameColor: String { current == .italian ? "Stesso colore" : "Same color" }
    static var shapesTutorialSameShape: String { current == .italian ? "Stessa forma" : "Same shape" }
    static var shapesTutorialNoMatch: String { current == .italian ? "Niente in comune" : "Nothing in common" }
    static var shapesTutorialGotIt: String { current == .italian ? "Ho Capito!" : "Got It!" }

    // Tester Mode
    static var testerMode: String { current == .italian ? "MODALITÀ TESTER" : "TESTER MODE" }
    static var jumpToLevel: String { current == .italian ? "Salta a Livello" : "Jump to Level" }
    static var currentLevel: String { current == .italian ? "Attuale" : "Current" }
    static var reportBug: String { current == .italian ? "Segnala Bug" : "Report Bug" }
    static var betaThanks: String { current == .italian ? "Versione Beta - Grazie per il test!" : "Beta Version - Thanks for testing!" }
    static var quickJump: String { current == .italian ? "SALTO RAPIDO" : "QUICK JUMP" }
    static var customLevel: String { current == .italian ? "LIVELLO PERSONALIZZATO" : "CUSTOM LEVEL" }
    static var go: String { current == .italian ? "VAI" : "GO" }
    static var testerWarning: String { current == .italian ? "Il salto livello è solo per test. Le statistiche non vengono aggiornate." : "Level jump is for testing only. Statistics are not updated." }
    static var close: String { current == .italian ? "Chiudi" : "Close" }
    static var selectColor: String { current == .italian ? "Seleziona Colore" : "Select Color" }
    static var chooseColorComplete: String { current == .italian ? "Scegli Colore da Completare" : "Choose Color to Complete" }
    static var wandWillComplete: String { current == .italian ? "La bacchetta completerà un tubo di questo colore" : "The wand will complete a tube of this color" }

    // Power-ups
    static var powerUps: String { current == .italian ? "Power-ups" : "Power-ups" }
    static var coins: String { current == .italian ? "Monete" : "Coins" }
}

enum Difficulty: String, CaseIterable, Codable {
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"

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

    var localizedName: String {
        switch self {
        case .easy: return L10n.easy
        case .medium: return L10n.medium
        case .hard: return L10n.hard
        }
    }

    var localizedDescription: String {
        switch self {
        case .easy: return L10n.easyDesc
        case .medium: return L10n.mediumDesc
        case .hard: return L10n.hardDesc
        }
    }
}

@MainActor
class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    @AppStorage("soundEnabled") var soundEnabled: Bool = true
    @AppStorage("musicEnabled") var musicEnabled: Bool = true
    @AppStorage("vibrationEnabled") var vibrationEnabled: Bool = true
    @AppStorage("difficulty") private var difficultyRaw: String = Difficulty.medium.rawValue
    @AppStorage("language") private var languageRaw: String = AppLanguage.italian.rawValue
    @AppStorage("highScore") var highScore: Int = 0
    @AppStorage("totalStars") var totalStars: Int = 0
    @AppStorage("gamesCompleted") var gamesCompleted: Int = 0
    @AppStorage("coins") var coins: Int = 10  // Monete iniziali (poche per incentivare ads!)

    // Power-ups storage
    @AppStorage("powerUp_shuffle") var powerUpShuffle: Int = 1
    @AppStorage("powerUp_colorBomb") var powerUpColorBomb: Int = 0
    @AppStorage("powerUp_undoAll") var powerUpUndoAll: Int = 2
    @AppStorage("powerUp_freezeTimer") var powerUpFreezeTimer: Int = 0
    @AppStorage("powerUp_magicWand") var powerUpMagicWand: Int = 0

    var difficulty: Difficulty {
        get { Difficulty(rawValue: difficultyRaw) ?? .medium }
        set {
            difficultyRaw = newValue.rawValue
            objectWillChange.send()
        }
    }

    var language: AppLanguage {
        get { AppLanguage(rawValue: languageRaw) ?? .italian }
        set {
            languageRaw = newValue.rawValue
            objectWillChange.send()
        }
    }

    /// Mute globale - spegne suoni, musica e vibrazione
    var isMuted: Bool {
        get { !soundEnabled && !musicEnabled && !vibrationEnabled }
        set {
            if newValue {
                // Mute tutto
                soundEnabled = false
                musicEnabled = false
                vibrationEnabled = false
                AudioManager.shared.stopMusic()
            } else {
                // Riattiva tutto
                soundEnabled = true
                musicEnabled = true
                vibrationEnabled = true
            }
            objectWillChange.send()
        }
    }

    /// Toggle lingua IT/EN
    func toggleLanguage() {
        language = (language == .italian) ? .english : .italian
    }

    /// Toggle mute globale
    func toggleMute() {
        isMuted.toggle()
    }

    private init() {}

    func resetProgress() {
        UserDefaults.standard.set(1, forKey: "BallSortPuzzle_CurrentLevel_easy")
        UserDefaults.standard.set(1, forKey: "BallSortPuzzle_CurrentLevel_medium")
        UserDefaults.standard.set(1, forKey: "BallSortPuzzle_CurrentLevel_hard")
        highScore = 0
        totalStars = 0
        gamesCompleted = 0
        // Reset anche power-up e monete
        resetPowerUps()
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

    // MARK: - Power-ups Management

    func getPowerUpCount(_ type: PowerUpType) -> Int {
        switch type {
        case .shuffle: return powerUpShuffle
        case .colorBomb: return powerUpColorBomb
        case .undoAll: return powerUpUndoAll
        case .freezeTimer: return powerUpFreezeTimer
        case .magicWand: return powerUpMagicWand
        }
    }

    func setPowerUpCount(_ type: PowerUpType, count: Int) {
        switch type {
        case .shuffle: powerUpShuffle = count
        case .colorBomb: powerUpColorBomb = count
        case .undoAll: powerUpUndoAll = count
        case .freezeTimer: powerUpFreezeTimer = count
        case .magicWand: powerUpMagicWand = count
        }
        objectWillChange.send()
    }

    func canUsePowerUp(_ type: PowerUpType) -> Bool {
        // Può usare se ha quantità > 0 OPPURE se ha abbastanza monete
        return getPowerUpCount(type) > 0 || coins >= type.cost
    }

    func usePowerUp(_ type: PowerUpType) -> Bool {
        let currentCount = getPowerUpCount(type)

        if currentCount > 0 {
            // Ha power-up disponibili, usa dalla quantità
            setPowerUpCount(type, count: currentCount - 1)
            return true
        } else if coins >= type.cost {
            // Non ha power-up ma ha monete, paga direttamente
            coins -= type.cost
            objectWillChange.send()
            return true
        }

        return false
    }

    func canBuyPowerUp(_ type: PowerUpType) -> Bool {
        return coins >= type.cost
    }

    func buyPowerUp(_ type: PowerUpType) -> Bool {
        guard canBuyPowerUp(type) else { return false }
        coins -= type.cost
        setPowerUpCount(type, count: getPowerUpCount(type) + 1)
        return true
    }

    func addCoins(_ amount: Int) {
        coins += amount
        objectWillChange.send()
    }

    /// Calcola monete guadagnate per livello completato
    /// (Poche monete per incentivare la visione di ads!)
    func calculateCoinsEarned(level: Int, stars: Int, timeBonus: Bool) -> Int {
        var earned = 2  // Base: solo 2 monete per livello
        earned += stars  // Bonus stelle: 1 moneta per stella (max 3)

        // Bonus difficoltà
        switch difficulty {
        case .easy: break
        case .medium: earned += 1
        case .hard: earned += 2
        }

        // Bonus tempo
        if timeBonus {
            earned += 2
        }

        // Max ~10 monete per livello (difficile + 3 stelle + bonus tempo)
        return earned
    }

    func resetPowerUps() {
        powerUpShuffle = 1
        powerUpColorBomb = 0
        powerUpUndoAll = 2
        powerUpFreezeTimer = 0
        powerUpMagicWand = 0
        coins = 10  // Poche monete iniziali per incentivare ads!
    }
}
