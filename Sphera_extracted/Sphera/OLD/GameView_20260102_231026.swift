//
//  GameView.swift
//  BallSortPuzzle
//
//  Created on 2026-01-02.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var gameViewModel: GameViewModel
    @Binding var showMenu: Bool

    var body: some View {
        VStack(spacing: 20) {
            // Header
            GameHeaderView(
                level: gameViewModel.currentLevel,
                moves: gameViewModel.moves,
                onMenuTap: { showMenu = true },
                onRestartTap: { gameViewModel.restartLevel() }
            )

            Spacer()

            // Area di gioco con i tubi
            TubesContainerView(gameViewModel: gameViewModel)

            Spacer()

            // Pulsanti azione
            HStack(spacing: 20) {
                ActionButton(icon: "arrow.counterclockwise", title: "Ricomincia") {
                    gameViewModel.restartLevel()
                }

                ActionButton(icon: "plus.circle", title: "Aggiungi Tubo") {
                    withAnimation(.spring(response: 0.3)) {
                        gameViewModel.addEmptyTube()
                    }
                }
            }
            .padding(.bottom, 30)
        }
        .padding()
        .overlay {
            if gameViewModel.showWinAlert {
                WinOverlayView(
                    level: gameViewModel.currentLevel,
                    moves: gameViewModel.moves,
                    onNextLevel: {
                        gameViewModel.nextLevel()
                    }
                )
            }
        }
    }
}

struct GameHeaderView: View {
    let level: Int
    let moves: Int
    let onMenuTap: () -> Void
    let onRestartTap: () -> Void

    var body: some View {
        HStack {
            Button(action: onMenuTap) {
                Image(systemName: "house.fill")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(12)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }

            Spacer()

            VStack(spacing: 4) {
                Text("Livello \(level)")
                    .font(.title2.bold())
                    .foregroundColor(.white)

                Text("Mosse: \(moves)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()

            Button(action: onRestartTap) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(12)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
        }
    }
}

struct TubesContainerView: View {
    @ObservedObject var gameViewModel: GameViewModel

    var body: some View {
        let tubes = gameViewModel.gameState.tubes
        let columns = tubes.count <= 5 ? tubes.count : (tubes.count + 1) / 2

        VStack(spacing: 30) {
            // Prima riga
            HStack(spacing: 16) {
                ForEach(0..<min(columns, tubes.count), id: \.self) { index in
                    TubeView(
                        tube: tubes[index],
                        isSelected: gameViewModel.selectedTubeIndex == index,
                        onTap: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                gameViewModel.selectTube(at: index)
                            }
                        }
                    )
                }
            }

            // Seconda riga (se necessario)
            if tubes.count > columns {
                HStack(spacing: 16) {
                    ForEach(columns..<tubes.count, id: \.self) { index in
                        TubeView(
                            tube: tubes[index],
                            isSelected: gameViewModel.selectedTubeIndex == index,
                            onTap: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    gameViewModel.selectTube(at: index)
                                }
                            }
                        )
                    }
                }
            }
        }
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(.white.opacity(0.8))
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct WinOverlayView: View {
    let level: Int
    let moves: Int
    let onNextLevel: () -> Void

    @State private var showContent = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture { }

            VStack(spacing: 30) {
                // Stelle
                HStack(spacing: 20) {
                    ForEach(0..<3, id: \.self) { i in
                        Image(systemName: "star.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.yellow)
                            .shadow(color: .yellow.opacity(0.5), radius: 10)
                            .scaleEffect(showContent ? 1 : 0)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.6)
                                    .delay(Double(i) * 0.15),
                                value: showContent
                            )
                    }
                }

                Text("Complimenti!")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                VStack(spacing: 8) {
                    Text("Livello \(level) completato")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.9))

                    Text("in \(moves) mosse")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))
                }

                Button(action: onNextLevel) {
                    HStack {
                        Text("Prossimo Livello")
                            .font(.title3.bold())
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.ballGreen, .ballBlue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: .ballGreen.opacity(0.5), radius: 10, y: 5)
                }
            }
            .scaleEffect(showContent ? 1 : 0.5)
            .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showContent = true
            }
        }
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [Color.backgroundDark, Color.backgroundLight],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        GameView(gameViewModel: GameViewModel(), showMenu: .constant(false))
    }
}
