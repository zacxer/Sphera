//
//  GameState.swift
//  BallSortPuzzle
//
//  Created on 2026-01-02.
//

import Foundation

struct GameState: Codable {
    var tubes: [Tube]
    var moves: Int
    var currentLevel: Int
    var selectedTubeIndex: Int?

    init(tubes: [Tube] = [], moves: Int = 0, currentLevel: Int = 1) {
        self.tubes = tubes
        self.moves = moves
        self.currentLevel = currentLevel
        self.selectedTubeIndex = nil
    }

    var isWon: Bool {
        tubes.allSatisfy { tube in
            tube.isEmpty || tube.isComplete
        }
    }

    mutating func selectTube(at index: Int) -> MoveResult {
        guard index >= 0 && index < tubes.count else {
            return .invalid
        }

        // Se non c'è nessuna selezione, seleziona questo tubo
        if selectedTubeIndex == nil {
            // Non selezionare tubi vuoti o completi
            if tubes[index].isEmpty {
                return .invalid
            }
            if tubes[index].isComplete {
                return .invalid
            }
            selectedTubeIndex = index
            return .selected
        }

        // Se clicco sullo stesso tubo, deseleziona
        if selectedTubeIndex == index {
            selectedTubeIndex = nil
            return .deselected
        }

        // Prova a spostare la pallina
        return moveBall(from: selectedTubeIndex!, to: index)
    }

    mutating func moveBall(from sourceIndex: Int, to destIndex: Int) -> MoveResult {
        guard sourceIndex >= 0 && sourceIndex < tubes.count,
              destIndex >= 0 && destIndex < tubes.count,
              sourceIndex != destIndex else {
            selectedTubeIndex = nil
            return .invalid
        }

        guard let ball = tubes[sourceIndex].topBall else {
            selectedTubeIndex = nil
            return .invalid
        }

        guard tubes[destIndex].canReceiveBall(ball) else {
            selectedTubeIndex = nil
            return .invalid
        }

        // Esegui lo spostamento
        _ = tubes[sourceIndex].removeBall()
        _ = tubes[destIndex].addBall(ball)
        moves += 1
        selectedTubeIndex = nil

        if isWon {
            return .won
        }

        return .moved
    }
}

enum MoveResult {
    case selected
    case deselected
    case moved
    case won
    case invalid
}
