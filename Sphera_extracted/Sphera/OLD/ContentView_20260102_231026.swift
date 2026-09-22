//
//  ContentView.swift
//  BallSortPuzzle
//
//  Created on 2026-01-02.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameViewModel = GameViewModel()
    @State private var showMenu = true

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.backgroundDark, Color.backgroundLight],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if showMenu {
                MenuView(showMenu: $showMenu, gameViewModel: gameViewModel)
                    .transition(.opacity)
            } else {
                GameView(gameViewModel: gameViewModel, showMenu: $showMenu)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showMenu)
    }
}

#Preview {
    ContentView()
}
