//
//  Tube.swift
//  BallSortPuzzle
//
//  Created on 2026-01-02.
//

import Foundation

struct Tube: Identifiable, Equatable, Codable {
    let id: UUID
    var balls: [Ball]
    let capacity: Int

    init(id: UUID = UUID(), balls: [Ball] = [], capacity: Int = 4) {
        self.id = id
        self.balls = balls
        self.capacity = capacity
    }

    var isEmpty: Bool {
        balls.isEmpty
    }

    var isFull: Bool {
        balls.count >= capacity
    }

    var topBall: Ball? {
        balls.last
    }

    var isComplete: Bool {
        guard balls.count == capacity else { return false }
        guard let firstColor = balls.first?.ballColor else { return false }
        return balls.allSatisfy { $0.ballColor == firstColor }
    }

    var consecutiveTopBallsCount: Int {
        guard let topColor = topBall?.ballColor else { return 0 }
        var count = 0
        for ball in balls.reversed() {
            if ball.ballColor == topColor {
                count += 1
            } else {
                break
            }
        }
        return count
    }

    mutating func removeBall() -> Ball? {
        guard !isEmpty else { return nil }
        return balls.removeLast()
    }

    mutating func addBall(_ ball: Ball) -> Bool {
        guard !isFull else { return false }
        balls.append(ball)
        return true
    }

    func canReceiveBall(_ ball: Ball) -> Bool {
        if isEmpty { return true }
        if isFull { return false }
        return topBall?.ballColor == ball.ballColor
    }

    static func == (lhs: Tube, rhs: Tube) -> Bool {
        lhs.id == rhs.id && lhs.balls == rhs.balls
    }
}
