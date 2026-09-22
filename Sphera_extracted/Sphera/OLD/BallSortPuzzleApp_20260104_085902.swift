//
//  BallSortPuzzleApp.swift
//  BallSortPuzzle
//
//  Created on 2026-01-02.
//

import SwiftUI

@main
struct BallSortPuzzleApp: App {
    @State private var showSplash = true
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Main content
                ContentView()
                    .opacity(showSplash ? 0 : 1)

                // Splash screen
                if showSplash {
                    SplashScreenView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .preferredColorScheme(.dark)
            .onAppear {
                // Dopo 3.5 secondi, nascondi splash
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showSplash = false
                    }

                    // Richiedi permesso ATT dopo la splash (richiesto da Apple per AdMob)
                    Task {
                        // Piccolo delay per assicurare che l'UI sia pronta
                        try? await Task.sleep(nanoseconds: 500_000_000)
                        await ATTManager.shared.requestTrackingPermission()
                    }
                }
            }
        }
    }
}
