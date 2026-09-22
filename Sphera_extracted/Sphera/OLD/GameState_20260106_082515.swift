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
    // Per gestire undo con portali
    let actualDestIndex: Int?  // Se diverso da destIndex (portale)
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

    // MARK: - Tube Selection

    mutating func selectTube(at index: Int) -> MoveResult {
        guard index >= 0 && index < tubes.count else {
            return .invalid
        }

        // Se non c'è nessuna selezione, seleziona questo tubo
        if selectedTubeIndex == nil {
            // Non selezionare tubi vuoti
            if tubes[index].isEmpty {
                return .invalid
            }
            // Tubi completi: selezionabili solo se ci sono tubi tall (per spostare palline)
            if tubes[index].isComplete {
                let hasTallTube = tubes.contains { $0.type == .tall }
                if !hasTallTube {
                    return .invalid
                }
            }
            // Non selezionare tubi bloccati
            if tubes[index].isTubeLocked {
                return .invalid
            }
            // Non selezionare se non può rimuovere (frozen con 1 pallina congelata)
            if !tubes[index].canRemoveTop() {
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

    // MARK: - Move Ball

    mutating func moveBall(from sourceIndex: Int, to destIndex: Int) -> MoveResult {
        guard sourceIndex >= 0 && sourceIndex < tubes.count,
              destIndex >= 0 && destIndex < tubes.count,
              sourceIndex != destIndex else {
            selectedTubeIndex = nil
            return .invalid
        }

        // Verifica che il tubo sorgente possa rimuovere
        guard tubes[sourceIndex].canRemoveTop() else {
            selectedTubeIndex = nil
            return .invalid
        }

        guard let ball = tubes[sourceIndex].topBall else {
            selectedTubeIndex = nil
            return .invalid
        }

        // Determina la destinazione effettiva (considera portali)
        var actualDestIndex = destIndex

        // Gestione portali
        if tubes[destIndex].isPortal {
            if let linkedIndex = findLinkedPortalIndex(for: destIndex) {
                // La pallina va nel portale collegato
                if tubes[linkedIndex].canReceiveBall(ball) {
                    actualDestIndex = linkedIndex
                }
                // Se il portale collegato è pieno, prova la destinazione originale
            }
        }

        guard tubes[actualDestIndex].canReceiveBall(ball) else {
            selectedTubeIndex = nil
            return .invalid
        }

        // Salva la mossa nella history PRIMA di eseguirla
        let move = GameMove(
            sourceIndex: sourceIndex,
            destIndex: destIndex,
            ball: ball,
            actualDestIndex: actualDestIndex != destIndex ? actualDestIndex : nil
        )
        moveHistory.append(move)

        // Esegui lo spostamento
        _ = tubes[sourceIndex].removeBall()
        _ = tubes[actualDestIndex].addBall(ball)
        moves += 1
        selectedTubeIndex = nil

        // Processa i tubi speciali dopo la mossa
        _ = processSpecialTubes()

        if isWon {
            return .won
        }

        return .moved
    }

    // MARK: - Special Tubes Processing

    /// Chiamato dopo ogni mossa per aggiornare lo stato dei tubi speciali
    mutating func processSpecialTubes() -> [SpecialTubeEvent] {
        var events: [SpecialTubeEvent] = []

        for i in 0..<tubes.count {
            switch tubes[i].type {
            case .frozen:
                // Decrementa countdown
                if let countdown = tubes[i].freezeCountdown, countdown > 0 {
                    tubes[i].decrementFreezeCountdown()
                    if tubes[i].freezeCountdown == 0 {
                        events.append(.unfrozen(tubeIndex: i))
                    }
                }

            case .locked:
                // Il tubo si sblocca quando un tubo adiacente è completo
                // (semplificazione: si sblocca dopo 5 mosse)
                // Puoi modificare questa logica come preferisci
                break

            default:
                break
            }
        }

        return events
    }

    // MARK: - Portal Logic

    /// Trova l'indice del portale collegato
    func findLinkedPortalIndex(for tubeIndex: Int) -> Int? {
        let tube = tubes[tubeIndex]
        guard tube.isPortal else { return nil }

        // Se ha un linkedPortalId, usa quello
        if let linkedId = tube.linkedPortalId {
            return tubes.firstIndex { $0.id == linkedId }
        }

        // Altrimenti trova l'altro portale dello stesso colore
        let targetType: TubeType = tube.type == .portalA ? .portalB : .portalA

        for (index, otherTube) in tubes.enumerated() {
            if index != tubeIndex &&
               otherTube.type == targetType &&
               otherTube.portalColor == tube.portalColor {
                return index
            }
        }

        return nil
    }

    // MARK: - Undo

    /// Annulla l'ultima mossa
    mutating func undoLastMove() -> Bool {
        guard let lastMove = moveHistory.popLast() else {
            return false
        }

        // Determina da dove rimuovere la pallina
        let removeFromIndex = lastMove.actualDestIndex ?? lastMove.destIndex

        // Rimuovi la pallina dal tubo destinazione
        _ = tubes[removeFromIndex].removeBall()

        // Rimetti la pallina nel tubo sorgente
        _ = tubes[lastMove.sourceIndex].addBall(lastMove.ball)

        // Decrementa il contatore mosse
        moves = max(0, moves - 1)

        return true
    }

    // MARK: - Unlock Logic

    /// Sblocca un tubo locked specifico
    mutating func unlockTube(at index: Int) {
        guard index >= 0 && index < tubes.count else { return }
        tubes[index].unlock()
    }

    /// Sblocca tutti i tubi locked (per debugging o power-up)
    mutating func unlockAllTubes() {
        for i in 0..<tubes.count {
            if tubes[i].type == .locked {
                tubes[i].unlock()
            }
        }
    }
}

// MARK: - Move Result

enum MoveResult {
    case selected
    case deselected
    case moved
    case won
    case invalid
}

// MARK: - Special Tube Events

enum SpecialTubeEvent {
    case unfrozen(tubeIndex: Int)
    case unlocked(tubeIndex: Int)
    case portalUsed(fromIndex: Int, toIndex: Int)
}
