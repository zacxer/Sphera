//
//  RateAppManager.swift
//  BallSortPuzzle
//
//  Created on 2026-01-03.
//

import SwiftUI
import StoreKit

@MainActor
class RateAppManager {
    static let shared = RateAppManager()

    @AppStorage("levelsCompletedForRate") private var levelsCompleted: Int = 0
    @AppStorage("hasRequestedReview") private var hasRequestedReview: Bool = false
    @AppStorage("lastReviewRequestDate") private var lastReviewRequestDate: Double = 0

    private init() {}

    /// Controlla se mostrare il popup di recensione
    /// Viene mostrato dopo 5, 15 e 30 livelli completati
    func checkAndRequestReview() {
        levelsCompleted += 1

        // Non richiedere troppo spesso (minimo 30 giorni tra richieste)
        let daysSinceLastRequest = (Date().timeIntervalSince1970 - lastReviewRequestDate) / (60 * 60 * 24)
        guard daysSinceLastRequest >= 30 || lastReviewRequestDate == 0 else { return }

        // Mostra dopo 5, 15, 30, 50, 75, 100 livelli
        let milestones = [5, 15, 30, 50, 75, 100]

        if milestones.contains(levelsCompleted) {
            requestReview()
            lastReviewRequestDate = Date().timeIntervalSince1970
        }
    }

    /// Richiede la recensione usando StoreKit
    private func requestReview() {
        // Ottieni la scena attiva per iOS 16+
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    /// Reset per testing
    func resetForTesting() {
        levelsCompleted = 0
        hasRequestedReview = false
        lastReviewRequestDate = 0
    }
}
