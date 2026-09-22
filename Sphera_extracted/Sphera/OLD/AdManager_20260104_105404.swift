//
//  AdManager.swift
//  BallSortPuzzle
//
//  Created on 2026-01-03.
//  Updated on 2026-01-04 - Full AdMob Integration (SDK 12.x)
//

import Foundation
import GoogleMobileAds
import AppTrackingTransparency
import SwiftUI

@MainActor
class AdManager: NSObject, ObservableObject {
    static let shared = AdManager()

    // MARK: - Ad Unit IDs
    #if DEBUG
    // Test IDs (per sviluppo)
    private let bannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"
    private let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910"
    private let rewardedAdUnitID = "ca-app-pub-3940256099942544/1712485313"
    #else
    // Production IDs (REALI)
    private let bannerAdUnitID = "ca-app-pub-2053215380495624/2922886589"
    private let interstitialAdUnitID = "ca-app-pub-2053215380495624/9930298005"
    private let rewardedAdUnitID = "ca-app-pub-2053215380495624/1832316132"
    #endif

    // MARK: - Published Properties
    @Published var isInterstitialReady = false
    @Published var isRewardedReady = false
    @Published var showBanner = true

    // MARK: - Private Properties
    private var interstitialAd: InterstitialAd?
    private var rewardedAd: RewardedAd?
    private var rewardCompletion: ((Bool) -> Void)?

    /// Contatore livelli per mostrare interstitial
    private var levelsSinceLastAd: Int = 0

    /// Numero di livelli tra un interstitial e l'altro
    let levelsBetweenAds: Int = 3

    // MARK: - Timed Interstitial
    private var gameTimeTimer: Timer?
    private var secondsPlayed: Int = 0

    /// Secondi di gioco tra un interstitial e l'altro (10 minuti = 600 secondi)
    let secondsBetweenTimedAds: Int = 600

    /// Traccia se la musica era in riproduzione prima dell'ad
    private var wasMusicPlaying: Bool = false

    /// Notifica quando un ad fullscreen appare/scompare (per pausare il gioco)
    @Published var isShowingFullscreenAd: Bool = false

    // MARK: - Initialization
    override init() {
        super.init()
    }

    func initialize() {
        MobileAds.shared.start { [weak self] status in
            print("[AdMob] SDK initialized")
            print("[AdMob] Adapters: \(status.adapterStatusesByClassName)")

            Task { @MainActor in
                self?.loadInterstitialAd()
                self?.loadRewardedAd()
            }
        }
    }

    // MARK: - Banner Ad Unit ID Getter
    func getBannerAdUnitID() -> String {
        return bannerAdUnitID
    }

    // MARK: - Banner Visibility
    func setBannerVisibility(_ visible: Bool) {
        showBanner = visible
    }

    // MARK: - Game Time Tracking (per interstitial a tempo)

    /// Avvia il timer di gioco (chiamare quando inizia una partita)
    func startGameTimeTracking() {
        stopGameTimeTracking()
        secondsPlayed = 0
        gameTimeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.secondsPlayed += 1
                self?.checkTimedInterstitial()
            }
        }
    }

    /// Ferma il timer di gioco (chiamare quando si torna al menu)
    func stopGameTimeTracking() {
        gameTimeTimer?.invalidate()
        gameTimeTimer = nil
    }

    /// Controlla se mostrare interstitial a tempo
    private func checkTimedInterstitial() {
        if secondsPlayed >= secondsBetweenTimedAds && isInterstitialReady {
            showInterstitialAd()
            secondsPlayed = 0 // Reset timer
        }
    }

    // MARK: - Music Control for Ads

    private func pauseMusicForAd() {
        wasMusicPlaying = AudioManager.shared.isPlaying
        if wasMusicPlaying {
            AudioManager.shared.pauseMusic()
        }
    }

    private func resumeMusicAfterAd() {
        if wasMusicPlaying {
            AudioManager.shared.resumeMusic()
        }
    }

    // MARK: - Interstitial Ads
    func loadInterstitialAd() {
        let request = Request()
        InterstitialAd.load(with: interstitialAdUnitID, request: request) { [weak self] ad, error in
            Task { @MainActor in
                if let error = error {
                    print("[AdMob] Failed to load interstitial: \(error.localizedDescription)")
                    self?.isInterstitialReady = false
                    return
                }
                print("[AdMob] Interstitial ad loaded")
                self?.interstitialAd = ad
                self?.interstitialAd?.fullScreenContentDelegate = self
                self?.isInterstitialReady = true
            }
        }
    }

    func showInterstitialAd() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            print("[AdMob] No root view controller")
            return
        }

        // Find the topmost presented controller
        var topController = rootVC
        while let presented = topController.presentedViewController {
            topController = presented
        }

        if let ad = interstitialAd {
            pauseMusicForAd()
            ad.present(from: topController)
        } else {
            print("[AdMob] Interstitial not ready")
            loadInterstitialAd()
        }
    }

    /// Mostra interstitial se pronto e se e' il momento giusto (ogni N livelli)
    func showInterstitialIfReady() {
        levelsSinceLastAd += 1

        if levelsSinceLastAd >= levelsBetweenAds && isInterstitialReady {
            showInterstitialAd()
            levelsSinceLastAd = 0
        }
    }

    /// Forza la visualizzazione dell'interstitial
    func forceShowInterstitial() {
        if isInterstitialReady {
            showInterstitialAd()
        }
    }

    // MARK: - Rewarded Ads
    func loadRewardedAd() {
        let request = Request()
        RewardedAd.load(with: rewardedAdUnitID, request: request) { [weak self] ad, error in
            Task { @MainActor in
                if let error = error {
                    print("[AdMob] Failed to load rewarded: \(error.localizedDescription)")
                    self?.isRewardedReady = false
                    return
                }
                print("[AdMob] Rewarded ad loaded")
                self?.rewardedAd = ad
                self?.rewardedAd?.fullScreenContentDelegate = self
                self?.isRewardedReady = true
            }
        }
    }

    func showRewardedAd(completion: @escaping (Bool) -> Void) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            print("[AdMob] No root view controller")
            completion(false)
            return
        }

        // Find the topmost presented controller
        var topController = rootVC
        while let presented = topController.presentedViewController {
            topController = presented
        }

        guard let ad = rewardedAd else {
            print("[AdMob] Rewarded ad not ready")
            completion(false)
            loadRewardedAd()
            return
        }

        rewardCompletion = completion

        // Pausa musica prima di mostrare l'ad
        pauseMusicForAd()

        ad.present(from: topController) { [weak self] in
            let reward = ad.adReward
            print("[AdMob] User earned reward: \(reward.amount) \(reward.type)")
            Task { @MainActor in
                self?.rewardCompletion?(true)
                self?.rewardCompletion = nil
            }
        }
    }

    /// Mostra rewarded ad con tipo specifico (per compatibilita' con codice esistente)
    func showRewardedAd(rewardType: RewardType, completion: @escaping (Bool) -> Void) {
        showRewardedAd(completion: completion)
    }

    /// Verifica se il rewarded e' disponibile
    func isRewardedAvailable() -> Bool {
        return isRewardedReady
    }

    // MARK: - Reset
    func resetLevelCounter() {
        levelsSinceLastAd = 0
    }

    func resetTimedCounter() {
        secondsPlayed = 0
    }
}

// MARK: - FullScreenContentDelegate
extension AdManager: FullScreenContentDelegate {

    nonisolated func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        Task { @MainActor in
            print("[AdMob] Ad dismissed")

            // Ad non più visibile
            isShowingFullscreenAd = false

            // Riprendi musica dopo l'ad
            resumeMusicAfterAd()

            if ad is InterstitialAd {
                isInterstitialReady = false
                loadInterstitialAd()
            } else if ad is RewardedAd {
                isRewardedReady = false
                loadRewardedAd()
            }
        }
    }

    nonisolated func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        Task { @MainActor in
            print("[AdMob] Ad failed to present: \(error.localizedDescription)")

            // Ad non più visibile
            isShowingFullscreenAd = false

            // Riprendi musica se l'ad fallisce
            resumeMusicAfterAd()

            if ad is InterstitialAd {
                isInterstitialReady = false
                loadInterstitialAd()
            } else if ad is RewardedAd {
                isRewardedReady = false
                rewardCompletion?(false)
                rewardCompletion = nil
                loadRewardedAd()
            }
        }
    }

    nonisolated func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        Task { @MainActor in
            print("[AdMob] Ad will present")
            isShowingFullscreenAd = true
        }
    }
}

// MARK: - Reward Types

enum RewardType: String {
    case undo = "undo"
    case hint = "hint"
    case extraTube = "extra_tube"
    case coins = "coins"

    var rewardAmount: Int {
        switch self {
        case .undo: return 3
        case .hint: return 2
        case .extraTube: return 1
        case .coins: return 25
        }
    }
}
