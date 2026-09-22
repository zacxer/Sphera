//
//  Level.swift
//  BallSortPuzzle
//
//  Created on 2026-01-02.
//

import Foundation

struct Level {
    let number: Int
    let numberOfColors: Int
    let numberOfEmptyTubes: Int
    let ballsPerTube: Int

    init(number: Int) {
        self.number = number
        self.ballsPerTube = 4

        // Progressione della difficoltà
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
        case 51...75:
            numberOfColors = 7
            numberOfEmptyTubes = 2
        default:
            numberOfColors = min(8, 3 + number / 20)
            numberOfEmptyTubes = 2
        }
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

        // Mischia le palline
        allBalls.shuffle()

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
}
