//
//  GameState.swift
//  BallSortPuzzle
//
//  Created on 2026-01-02.
//

import Foundation

// Struttura per salvare una mossa (per Undo)
struct GameMove: Codable {
    let sourceIndex: Int
    let destIndex: Int
    let ball: Ball
}

struct GameState: Codable {
    var tubes: [Tube]
    var moves: Int
    var currentLevel: Int
    var selectedTubeIndex: Int?
    var moveHistory: [GameMove] = []  // History per Undo

    init(tubes: [Tube] = [], moves: Int = 0, currentLevel: Int = 1) {
        self.tubes = tubes
        self.moves = moves
        self.currentLevel = currentLevel
        self.selectedTubeIndex = nil
        self.moveHistory = []
    }

    var isWon: Bool {
        tubes.allSatisfy { tube in
            tube.isEmpty || tube.isComplete
        }
    }

    var canUndo: Bool {
        !moveHistory.isEmpty
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

        // Salva la mossa nella history PRIMA di eseguirla
        let move = GameMove(sourceIndex: sourceIndex, destIndex: destIndex, ball: ball)
        moveHistory.append(move)

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

    // Annulla l'ultima mossa
    mutating func undoLastMove() -> Bool {
        guard let lastMove = moveHistory.popLast() else {
            return false
        }

        // Rimuovi la pallina dal tubo destinazione
        _ = tubes[lastMove.destIndex].removeBall()

        // Rimetti la pallina nel tubo sorgente
        _ = tubes[lastMove.sourceIndex].addBall(lastMove.ball)

        // Decrementa il contatore mosse
        moves = max(0, moves - 1)

        return true
    }
}

enum MoveResult {
    case selected
    case deselected
    case moved
    case won
    case invalid
}
