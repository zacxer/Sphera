//
//  AdManager.swift
//  BallSortPuzzle
//
//  Created on 2026-01-03.
//
//  NOTA: Per usare AdMob, aggiungi il pacchetto Google Mobile Ads SDK:
//  File > Add Package Dependencies > https://github.com/googleads/swift-package-manager-google-mobile-ads
//

import SwiftUI

// MARK: - Placeholder per quando AdMob non e' ancora integrato

/// Manager per la gestione delle pubblicita AdMob
/// Questo e' un placeholder - sostituire con l'implementazione reale dopo aver aggiunto il SDK
@MainActor
class AdManager: ObservableObject {
    static let shared = AdManager()

    // MARK: - Ad Unit IDs (TEST - sostituire con ID reali in produzione)

    /// Banner Ad Unit ID - TEST
    let bannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"

    /// Interstitial Ad Unit ID - TEST
    let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910"

    /// Rewarded Ad Unit ID - TEST
    let rewardedAdUnitID = "ca-app-pub-3940256099942544/1712485313"

    // MARK: - State

    @Published var isInterstitialReady: Bool = false
    @Published var isRewardedReady: Bool = true  // true per testing, mettere false quando AdMob è integrato
    @Published var showBanner: Bool = true

    /// Contatore livelli per mostrare interstitial
    private var levelsSinceLastAd: Int = 0

    /// Numero di livelli tra un interstitial e l'altro
    let levelsBetweenAds: Int = 3

    private init() {
        // Inizializzazione SDK AdMob
        // GADMobileAds.sharedInstance().start(completionHandler: nil)
        print("[AdManager] Placeholder inizializzato - Aggiungere Google Mobile Ads SDK per funzionalita complete")
    }

    // MARK: - Banner Ads

    /// Mostra/nasconde il banner
    func setBannerVisibility(_ visible: Bool) {
        showBanner = visible
    }

    // MARK: - Interstitial Ads

    /// Carica un interstitial
    func loadInterstitial() {
        // Implementare con:
        // GADInterstitialAd.load(withAdUnitID: interstitialAdUnitID, request: GADRequest()) { ad, error in ... }
        print("[AdManager] loadInterstitial() - Placeholder")
    }

    /// Mostra interstitial se pronto e se e' il momento giusto
    func showInterstitialIfReady() {
        levelsSinceLastAd += 1

        if levelsSinceLastAd >= levelsBetweenAds && isInterstitialReady {
            // Implementare con:
            // interstitialAd?.present(fromRootViewController: rootVC)
            print("[AdManager] Mostrando interstitial - Placeholder")
            levelsSinceLastAd = 0
            isInterstitialReady = false
            loadInterstitial() // Pre-carica il prossimo
        }
    }

    /// Forza la visualizzazione dell'interstitial
    func forceShowInterstitial() {
        if isInterstitialReady {
            print("[AdManager] Forza interstitial - Placeholder")
            isInterstitialReady = false
            loadInterstitial()
        }
    }

    // MARK: - Rewarded Ads

    /// Carica un rewarded ad
    func loadRewardedAd() {
        // Implementare con:
        // GADRewardedAd.load(withAdUnitID: rewardedAdUnitID, request: GADRequest()) { ad, error in ... }
        print("[AdManager] loadRewardedAd() - Placeholder")
    }

    /// Mostra rewarded ad con callback per ricompensa
    /// - Parameters:
    ///   - rewardType: Tipo di ricompensa ("undo" o "hint")
    ///   - completion: Callback con successo (true) o fallimento (false)
    func showRewardedAd(rewardType: RewardType, completion: @escaping (Bool) -> Void) {
        guard isRewardedReady else {
            print("[AdManager] Rewarded non pronto")
            completion(false)
            return
        }

        // Implementare con:
        // rewardedAd?.present(fromRootViewController: rootVC) { [weak self] in
        //     let reward = self?.rewardedAd?.adReward
        //     completion(true)
        // }

        print("[AdManager] Mostrando rewarded per \(rewardType) - Placeholder")

        // Simulazione successo per testing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            completion(true)
            // Ricarica il rewarded per il prossimo uso (in testing rimane sempre pronto)
            self?.isRewardedReady = true
        }
    }

    /// Verifica se il rewarded e' disponibile
    func isRewardedAvailable() -> Bool {
        return isRewardedReady
    }

    // MARK: - Reset

    /// Reset del contatore per testing
    func resetLevelCounter() {
        levelsSinceLastAd = 0
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
        case .coins: return 25  // Monete per AD
        }
    }
}

// MARK: - Istruzioni per Integrazione AdMob

/*
 PASSAGGI PER INTEGRARE ADMOB:

 1. Aggiungi Google Mobile Ads SDK:
    - File > Add Package Dependencies
    - URL: https://github.com/googleads/swift-package-manager-google-mobile-ads
    - Seleziona "GoogleMobileAds"

 2. Configura Info.plist:
    <key>GADApplicationIdentifier</key>
    <string>ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX</string>

    <key>SKAdNetworkItems</key>
    <array>
      <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>cstr6suwn9.skadnetwork</string>
      </dict>
      <!-- Altri SKAdNetwork IDs da Google -->
    </array>

 3. Inizializza in BallSortPuzzleApp.swift:
    import GoogleMobileAds

    init() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }

 4. Sostituisci gli Ad Unit ID di test con quelli reali:
    - Vai su https://admob.google.com
    - Crea un'app e ottieni gli Ad Unit ID
    - Sostituisci i placeholder in questo file

 5. Implementa le funzioni placeholder con il codice reale
*/
