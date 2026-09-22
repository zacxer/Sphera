//
//  Level.swift
//  BallSortPuzzle
//
//  Created on 2026-01-02.
//  Updated: 2026-01-03 - FASE 3: Forme multiple
//

import Foundation

struct Level {
    let number: Int
    let difficulty: Difficulty
    let numberOfColors: Int
    let numberOfEmptyTubes: Int
    let ballsPerTube: Int
    let optimalMoves: Int
    let availableShapes: [ShapeType]

    init(number: Int, difficulty: Difficulty = .medium) {
        self.number = number
        self.difficulty = difficulty
        self.ballsPerTube = 4

        // FASE 3: Determina forme disponibili in base al livello
        self.availableShapes = Level.determineAvailableShapes(level: number, difficulty: difficulty)

        // Configurazione basata sulla difficoltà
        switch difficulty {
        case .easy:
            // Facile: 3-4 colori, progressione lenta
            switch number {
            case 1...10:
                numberOfColors = 3
                numberOfEmptyTubes = 2
            case 11...25:
                numberOfColors = 4
                numberOfEmptyTubes = 2
            default:
                numberOfColors = 4
                numberOfEmptyTubes = 2
            }

        case .medium:
            // Medio: 4-6 colori, progressione normale
            switch number {
            case 1...5:
                numberOfColors = 3
                numberOfEmptyTubes = 2
            case 6...15:
                numberOfColors = 4
                numberOfEmptyTubes = 2
            case 16...30:
                numberOfColors = 5
                numberOfEmptyTubes = 2
            case 31...50:
                numberOfColors = 6
                numberOfEmptyTubes = 2
            default:
                numberOfColors = 6
                numberOfEmptyTubes = 2
            }

        case .hard:
            // Difficile: 5-7 colori, progressione veloce
            // MAX 7 colori + 2 vuoti = 9 tubi (+ 1 extra = 10 max)
            switch number {
            case 1...3:
                numberOfColors = 4
                numberOfEmptyTubes = 2
            case 4...10:
                numberOfColors = 5
                numberOfEmptyTubes = 2
            case 11...20:
                numberOfColors = 6
                numberOfEmptyTubes = 2
            default:
                // Max 7 colori per non superare 10 tubi totali con extra
                numberOfColors = 7
                numberOfEmptyTubes = 2
            }
        }

        // Stima mosse ottimali basata sul numero di colori (più realistico)
        // Ogni colore richiede circa 3-4 mosse in media per essere completato
        let baseMovesPerColor = 4
        let baseMoves = numberOfColors * baseMovesPerColor

        // Aggiusta per difficoltà (su Hard i puzzle sono più intricati)
        let difficultyMultiplier: Double
        switch difficulty {
        case .easy:
            difficultyMultiplier = 0.9   // -10% (puzzle più semplici)
        case .medium:
            difficultyMultiplier = 1.0   // Base
        case .hard:
            difficultyMultiplier = 1.2   // +20% (puzzle più complessi)
        }

        // Mosse ottimali = colori * 4 * difficoltà (minimo 10)
        self.optimalMoves = max(10, Int(Double(baseMoves) * difficultyMultiplier))
    }

    var totalTubes: Int {
        numberOfColors + numberOfEmptyTubes
    }

    /// FASE 3: True se questo livello ha forme multiple
    var hasMultipleShapes: Bool {
        availableShapes.count > 1
    }

    /// FASE 3: True se è il primo livello con nuove forme (per mostrare tutorial)
    var isFirstShapeIntroduction: Bool {
        // Primo livello con forme oltre alle palline
        let previousShapes = Level.determineAvailableShapes(level: number - 1, difficulty: difficulty)
        return availableShapes.count > previousShapes.count
    }

    // MARK: - FASE 3: Determine Available Shapes

    /// Determina quali forme sono disponibili in base al livello e difficoltà
    static func determineAvailableShapes(level: Int, difficulty: Difficulty) -> [ShapeType] {
        // Offset per difficoltà (le forme arrivano prima su difficile)
        let levelOffset: Int
        switch difficulty {
        case .easy:
            levelOffset = 0   // Forme arrivano ai livelli standard
        case .medium:
            levelOffset = -5  // Forme arrivano 5 livelli prima
        case .hard:
            levelOffset = -10 // Forme arrivano 10 livelli prima
        }

        let effectiveLevel = level + levelOffset

        switch effectiveLevel {
        case ...15:
            // Solo palline
            return [.ball]
        case 16...25:
            // Palline + Cubi
            return [.ball, .cube]
        case 26...35:
            // + Piramidi
            return [.ball, .cube, .pyramid]
        case 36...45:
            // + Stelle
            return [.ball, .cube, .pyramid, .star]
        default:
            // Tutte le forme
            return ShapeType.allCases
        }
    }

    // MARK: - Generate Tubes with Special Types (REVERSE SHUFFLE - SEMPRE RISOLVIBILE)

    func generateTubes() -> [Tube] {
        let tubeTypes = determineTubeTypes()

        // STEP 1: Crea la SOLUZIONE (ogni tubo con pezzi IDENTICI - stesso colore E forma)
        var tubes: [Tube] = []
        var portalAId: UUID?
        var portalBId: UUID?

        // FASE 3: Assegna forme ai tubi in modo bilanciato
        let shapesForTubes = distributeShapesToTubes()

        for i in 0..<tubeTypes.count {
            let tubeType = tubeTypes[i]
            let isEmptyTube = i >= numberOfColors

            if isEmptyTube {
                // Tubo vuoto
                let tube = Tube(balls: [], type: tubeType)
                tubes.append(tube)
            } else {
                // Tubo con pezzi tutti IDENTICI (stesso colore E forma) = SOLUZIONE
                let color = BallColor(rawValue: i) ?? .red
                let shape = shapesForTubes[i]
                let capacity = tubeType.capacity
                var tubeBalls: [Ball] = []

                for _ in 0..<capacity {
                    tubeBalls.append(Ball(color: color, shape: shape))
                }

                let tube = Tube(balls: tubeBalls, type: tubeType)

                // Gestione ID portali
                if tubeType == .portalA {
                    portalAId = tube.id
                } else if tubeType == .portalB {
                    portalBId = tube.id
                }

                tubes.append(tube)
            }
        }

        // Collega i portali
        if let aId = portalAId, let bId = portalBId {
            for i in 0..<tubes.count {
                if tubes[i].id == aId {
                    tubes[i].linkedPortalId = bId
                } else if tubes[i].id == bId {
                    tubes[i].linkedPortalId = aId
                }
            }
        }

        // STEP 2: REVERSE SHUFFLE - Applica mosse casuali al contrario
        // Questo garantisce che il puzzle sia SEMPRE risolvibile
        let shuffleMoves = calculateShuffleMoves()
        tubes = reverseShuffleTubes(tubes, moves: shuffleMoves)

        return tubes
    }

    // Calcola quante mosse di shuffle fare in base al livello
    private func calculateShuffleMoves() -> Int {
        let baseMoves: Int
        switch difficulty {
        case .easy:
            baseMoves = 15 + (number * 2)
        case .medium:
            baseMoves = 25 + (number * 3)
        case .hard:
            baseMoves = 40 + (number * 4)
        }
        // Max 200 mosse per non rallentare troppo
        return min(baseMoves, 200)
    }

    // Applica mosse casuali "al contrario" per mescolare mantenendo risolvibilità
    // NOTA: Durante la generazione, permettiamo spostamenti da/verso TUTTI i tubi (inclusi frozen/locked)
    private func reverseShuffleTubes(_ initialTubes: [Tube], moves: Int) -> [Tube] {
        var tubes = initialTubes
        var completedMoves = 0
        var attempts = 0
        let maxAttempts = moves * 10  // Evita loop infiniti

        while completedMoves < moves && attempts < maxAttempts {
            attempts += 1

            // Durante generazione: TUTTI i tubi non vuoti sono sorgenti valide
            let validSources = tubes.enumerated().filter { index, tube in
                !tube.isEmpty
            }.map { $0.offset }

            guard !validSources.isEmpty else { break }

            // Scegli un tubo sorgente casuale
            let sourceIndex = validSources.randomElement()!
            guard tubes[sourceIndex].topBall != nil else { continue }

            // Durante generazione: TUTTE le destinazioni non piene sono valide
            let validDests = tubes.enumerated().filter { index, tube in
                index != sourceIndex && !tube.isFull
            }.map { $0.offset }

            guard !validDests.isEmpty else { continue }

            // Scegli destinazione casuale
            let destIndex = validDests.randomElement()!

            // Esegui la mossa (forza rimozione/aggiunta)
            if !tubes[sourceIndex].balls.isEmpty {
                let removedBall = tubes[sourceIndex].balls.removeLast()
                tubes[destIndex].balls.append(removedBall)
                completedMoves += 1
            }
        }

        // Verifica finale: assicurati che nessun tubo sia già completo
        // Se qualcuno lo è, fai qualche mossa extra
        var extraAttempts = 0
        while tubesHaveCompletedTube(tubes) && extraAttempts < 50 {
            extraAttempts += 1
            tubes = breakCompletedTubes(tubes)
        }

        return tubes
    }

    // Controlla se c'è un tubo già completo
    private func tubesHaveCompletedTube(_ tubes: [Tube]) -> Bool {
        for tube in tubes {
            if tube.isComplete && !tube.isEmpty {
                return true
            }
        }
        return false
    }

    // Rompe i tubi completi spostando una pallina
    // NOTA: Durante la generazione, FORZIAMO la rottura anche dei tubi frozen/locked
    private func breakCompletedTubes(_ initialTubes: [Tube]) -> [Tube] {
        var tubes = initialTubes

        for i in 0..<tubes.count {
            // Durante la generazione, rompi TUTTI i tubi completi inclusi frozen/locked
            if tubes[i].isComplete && !tubes[i].isEmpty {
                // Trova un tubo destinazione valido (non pieno e non locked)
                for j in 0..<tubes.count {
                    if i != j && !tubes[j].isFull && tubes[j].type != .locked {
                        // Forza rimozione pallina (ignora canRemoveTop per generazione)
                        if !tubes[i].balls.isEmpty {
                            let ball = tubes[i].balls.removeLast()
                            tubes[j].balls.append(ball)
                            return tubes  // Una mossa alla volta
                        }
                    }
                }
            }
        }

        return tubes
    }

    // MARK: - FASE 3: Distribute Shapes to Tubes

    /// Distribuisce le forme ai tubi in modo bilanciato
    private func distributeShapesToTubes() -> [ShapeType] {
        var shapes: [ShapeType] = []

        if availableShapes.count == 1 {
            // Solo palline - assegna .ball a tutti
            for _ in 0..<numberOfColors {
                shapes.append(.ball)
            }
        } else {
            // Forme multiple: distribuisci in modo bilanciato e casuale
            // Ogni forma deve apparire almeno una volta (se possibile)
            var shapesPool: [ShapeType] = []

            // Prima, aggiungi ogni forma disponibile almeno una volta
            for shape in availableShapes {
                shapesPool.append(shape)
            }

            // Poi riempi il resto in modo casuale
            while shapesPool.count < numberOfColors {
                if let randomShape = availableShapes.randomElement() {
                    shapesPool.append(randomShape)
                }
            }

            // Mescola e tronca alla dimensione necessaria
            shapes = Array(shapesPool.shuffled().prefix(numberOfColors))
        }

        return shapes
    }

    // MARK: - Determine Tube Types Based on Level and Difficulty

    private func determineTubeTypes() -> [TubeType] {
        var types: [TubeType] = []

        // Livelli facili (1-15 per ogni difficoltà) = solo tubi normali
        let introLevels: Int
        switch difficulty {
        case .easy:
            introLevels = 20  // Su Easy, primi 20 livelli sono normali
        case .medium:
            introLevels = 15  // Su Medium, primi 15 livelli sono normali
        case .hard:
            introLevels = 10  // Su Hard, primi 10 livelli sono normali
        }

        if number <= introLevels {
            // Solo tubi normali
            for _ in 0..<numberOfColors {
                types.append(.normal)
            }
            for _ in 0..<numberOfEmptyTubes {
                types.append(.normal)
            }
            return types
        }

        // Livelli avanzati: aggiungi tubi speciali progressivamente
        let advancedLevel = number - introLevels

        switch difficulty {
        case .easy:
            // Easy: solo frozen dopo livello 20
            types = generateTypesForEasy(advancedLevel: advancedLevel)

        case .medium:
            // Medium: frozen, tall, poi locked
            types = generateTypesForMedium(advancedLevel: advancedLevel)

        case .hard:
            // Hard: tutti i tipi più velocemente
            types = generateTypesForHard(advancedLevel: advancedLevel)
        }

        // RANDOMIZZA le posizioni dei tubi pieni (non quelli vuoti!)
        types = randomizeTubePositions(types)

        return types
    }

    // Mescola le posizioni dei tubi pieni mantenendo i vuoti alla fine
    private func randomizeTubePositions(_ types: [TubeType]) -> [TubeType] {
        // Separa tubi pieni (primi numberOfColors) dai vuoti
        let filledTubes = Array(types.prefix(numberOfColors))
        let emptyTubes = Array(types.suffix(numberOfEmptyTubes))

        // Mescola solo i tubi pieni
        let shuffledFilled = filledTubes.shuffled()

        // Gestione speciale per portali: devono rimanere vicini ma non adiacenti
        // per evitare confusione (opzionale, li lasciamo mescolati)

        // Ricombina: tubi pieni mescolati + tubi vuoti
        return shuffledFilled + emptyTubes
    }

    private func generateTypesForEasy(advancedLevel: Int) -> [TubeType] {
        var types: [TubeType] = Array(repeating: .normal, count: numberOfColors)

        // Dopo livello 20: aggiungi 1 frozen
        if advancedLevel > 0 && numberOfColors >= 3 {
            types[0] = .frozen
        }

        // Tubi vuoti
        for _ in 0..<numberOfEmptyTubes {
            types.append(.normal)
        }

        return types
    }

    private func generateTypesForMedium(advancedLevel: Int) -> [TubeType] {
        var types: [TubeType] = Array(repeating: .normal, count: numberOfColors)

        if numberOfColors >= 3 {
            // Livello 16-20: 1 frozen
            if advancedLevel >= 1 {
                types[0] = .frozen
            }

            // Livello 21-25: frozen + tall
            if advancedLevel >= 6 && numberOfColors >= 4 {
                types[1] = .tall
            }

            // Livello 26-30: frozen + tall + locked
            if advancedLevel >= 11 && numberOfColors >= 5 {
                types[2] = .locked
            }

            // Livello 31+: frozen + tall + locked + secondo frozen
            if advancedLevel >= 16 && numberOfColors >= 6 {
                types[3] = .frozen
            }
        }

        // Tubi vuoti
        for _ in 0..<numberOfEmptyTubes {
            types.append(.normal)
        }

        return types
    }

    private func generateTypesForHard(advancedLevel: Int) -> [TubeType] {
        var types: [TubeType] = Array(repeating: .normal, count: numberOfColors)

        if numberOfColors >= 4 {
            // Livello 11-15: frozen + tall
            if advancedLevel >= 1 {
                types[0] = .frozen
                types[1] = .tall
            }

            // Livello 16-20: frozen + tall + locked
            if advancedLevel >= 6 && numberOfColors >= 5 {
                types[2] = .locked
            }

            // Livello 21-25: aggiungi portali
            if advancedLevel >= 11 && numberOfColors >= 6 {
                types[3] = .portalA
                types[4] = .portalB
            }

            // Livello 26+: secondo frozen per difficoltà extra
            if advancedLevel >= 16 && numberOfColors >= 7 {
                types[5] = .frozen
            }
        }

        // Tubi vuoti
        for _ in 0..<numberOfEmptyTubes {
            types.append(.normal)
        }

        return types
    }

}
