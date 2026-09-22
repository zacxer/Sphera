//
//  AppEnvironment.swift
//  BallSortPuzzle
//
//  Created on 2026-01-04.
//  Rileva se l'app è in Debug, TestFlight o App Store
//

import Foundation

enum AppEnvironment {

    /// True se siamo in DEBUG mode
    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    /// True se l'app è installata via TestFlight
    static var isTestFlight: Bool {
        guard let receiptURL = Bundle.main.appStoreReceiptURL else {
            return false
        }
        return receiptURL.lastPathComponent == "sandboxReceipt"
    }

    /// True se siamo in App Store (produzione)
    static var isAppStore: Bool {
        return !isDebug && !isTestFlight
    }

    /// True se è una build beta (Debug o TestFlight)
    /// Usare questo per mostrare funzionalità beta
    static var isBetaBuild: Bool {
        return isDebug || isTestFlight
    }

    /// Nome ambiente corrente (per debug)
    static var environmentName: String {
        if isDebug {
            return "Debug"
        } else if isTestFlight {
            return "TestFlight"
        } else {
            return "App Store"
        }
    }
}
