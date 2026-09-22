//
//  Level.swift
//  BallSortPuzzle
//
//  Created on 2026-01-02.
//

import Foundation

struct Level {
    let number: Int
    let difficulty: Difficulty
    let numberOfColors: Int
    let numberOfEmptyTubes: Int
    let ballsPerTube: Int
    let optimalMoves: Int

    init(number: Int, difficulty: Difficulty = .medium) {
        self.number = number
        self.difficulty = difficulty
        self.ballsPerTube = 4

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
            // Difficile: 5-8 colori, progressione veloce
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
            case 21...35:
                numberOfColors = 7
                numberOfEmptyTubes = 2
            default:
                numberOfColors = 8
                numberOfEmptyTubes = 2
            }
        }

        // Stima mosse ottimali (approssimazione)
        self.optimalMoves = numberOfColors * ballsPerTube
    }

    var totalTubes: Int {
        numberOfColors + numberOfEmptyTubes
    }

    // MARK: - Generate Tubes with Special Types

    func generateTubes() -> [Tube] {
        var allBalls: [Ball] = []

        // Determina capacità (tall tubes usano 6)
        let tubeTypes = determineTubeTypes()
        let hasTallTube = tubeTypes.contains(.tall)

        // Crea palline per ogni colore
        for colorIndex in 0..<numberOfColors {
            let color = BallColor(rawValue: colorIndex) ?? .red
            // Per tubi tall, servono 6 palline di quel colore
            let ballCount = (hasTallTube && colorIndex == 0) ? 6 : ballsPerTube
            for _ in 0..<ballCount {
                allBalls.append(Ball(color: color))
            }
        }

        // Mischia le palline
        allBalls.shuffle()

        // Verifica che il puzzle sia risolvibile
        var isValid = false
        var attempts = 0

        while !isValid && attempts < 100 {
            allBalls.shuffle()
            isValid = validatePuzzle(balls: allBalls, tubeTypes: tubeTypes)
            attempts += 1
        }

        // Distribuisci le palline nei tubi
        var tubes: [Tube] = []
        var ballIndex = 0
        var portalAId: UUID?
        var portalBId: UUID?

        for i in 0..<tubeTypes.count {
            let tubeType = tubeTypes[i]
            let capacity = tubeType.capacity

            // Determina quante palline mettere in questo tubo
            let isEmptyTube = i >= numberOfColors

            if isEmptyTube {
                // Tubo vuoto
                let tube = Tube(balls: [], type: tubeType)
                tubes.append(tube)
            } else {
                // Tubo con palline
                var tubeBalls: [Ball] = []
                let ballCountForThisTube = min(capacity, allBalls.count - ballIndex)

                for _ in 0..<ballCountForThisTube {
                    if ballIndex < allBalls.count {
                        tubeBalls.append(allBalls[ballIndex])
                        ballIndex += 1
                    }
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

        return tubes
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

        return types
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

            // Livello 31+: aggiungi rotating
            if advancedLevel >= 16 && numberOfColors >= 6 {
                types[3] = .rotating
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

            // Livello 26+: aggiungi rotating
            if advancedLevel >= 16 && numberOfColors >= 7 {
                types[5] = .rotating
            }
        }

        // Tubi vuoti
        for _ in 0..<numberOfEmptyTubes {
            types.append(.normal)
        }

        return types
    }

    // MARK: - Validation

    private func validatePuzzle(balls: [Ball], tubeTypes: [TubeType]) -> Bool {
        var ballIndex = 0

        for i in 0..<numberOfColors {
            let capacity = tubeTypes[i].capacity
            let tubeBalls = Array(balls[ballIndex..<min(ballIndex + capacity, balls.count)])
            ballIndex += capacity

            if tubeBalls.count == capacity {
                let firstColor = tubeBalls[0].ballColor
                if tubeBalls.allSatisfy({ $0.ballColor == firstColor }) {
                    return false  // Tubo già completo
                }
            }
        }
        return true
    }
}
