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

    func generateTubes() -> [Tube] {
        var allBalls: [Ball] = []

        // Crea 4 palline per ogni colore
        for colorIndex in 0..<numberOfColors {
            let color = BallColor(rawValue: colorIndex) ?? .red
            for _ in 0..<ballsPerTube {
                allBalls.append(Ball(color: color))
            }
        }

        // Mischia le palline (con seed per riproducibilità opzionale)
        allBalls.shuffle()

        // Verifica che il puzzle sia risolvibile (non tutte le palline dello stesso colore in un tubo)
        var isValid = false
        var attempts = 0

        while !isValid && attempts < 100 {
            allBalls.shuffle()
            isValid = validatePuzzle(balls: allBalls)
            attempts += 1
        }

        // Distribuisci le palline nei tubi
        var tubes: [Tube] = []
        var ballIndex = 0

        for _ in 0..<numberOfColors {
            var tubeBalls: [Ball] = []
            for _ in 0..<ballsPerTube {
                tubeBalls.append(allBalls[ballIndex])
                ballIndex += 1
            }
            tubes.append(Tube(balls: tubeBalls, capacity: ballsPerTube))
        }

        // Aggiungi tubi vuoti
        for _ in 0..<numberOfEmptyTubes {
            tubes.append(Tube(capacity: ballsPerTube))
        }

        return tubes
    }

    // Verifica che il puzzle non sia già risolto o troppo facile
    private func validatePuzzle(balls: [Ball]) -> Bool {
        // Controlla che nessun tubo abbia tutte palline dello stesso colore
        for i in stride(from: 0, to: balls.count, by: ballsPerTube) {
            let tubeBalls = Array(balls[i..<min(i + ballsPerTube, balls.count)])
            if tubeBalls.count == ballsPerTube {
                let firstColor = tubeBalls[0].ballColor
                if tubeBalls.allSatisfy({ $0.ballColor == firstColor }) {
                    return false
                }
            }
        }
        return true
    }
}
