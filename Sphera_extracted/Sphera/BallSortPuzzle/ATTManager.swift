//
//  ATTManager.swift
//  BallSortPuzzle
//
//  Created on 2026-01-04.
//  ATT (App Tracking Transparency) - Richiesto da Apple per AdMob
//

import AppTrackingTransparency
import AdSupport

@MainActor
class ATTManager {
    static let shared = ATTManager()

    private init() {}

    /// Stato corrente del permesso di tracking
    var trackingStatus: ATTrackingManager.AuthorizationStatus {
        ATTrackingManager.trackingAuthorizationStatus
    }

    /// True se l'utente ha autorizzato il tracking
    var isAuthorized: Bool {
        trackingStatus == .authorized
    }

    /// True se il permesso non è ancora stato richiesto
    var isNotDetermined: Bool {
        trackingStatus == .notDetermined
    }

    /// Richiede il permesso di tracking all'utente
    /// Deve essere chiamato dopo che l'app è diventata attiva
    func requestTrackingPermission() async {
        // Solo se non è ancora stato richiesto
        guard isNotDetermined else { return }

        // Richiedi permesso
        _ = await ATTrackingManager.requestTrackingAuthorization()
    }

    /// IDFA per AdMob (vuoto se non autorizzato)
    var advertisingIdentifier: String {
        guard isAuthorized else { return "" }
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
}
