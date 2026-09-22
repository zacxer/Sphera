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
        VStack(spacing: 16) {
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
                .padding(.horizontal, 8)

            Spacer()

            // Pulsanti azione
            HStack(spacing: 24) {
                ActionButton(icon: "arrow.counterclockwise", title: "Ricomincia", color: .ballRed) {
                    withAnimation(.spring(response: 0.3)) {
                        gameViewModel.restartLevel()
                    }
                }

                ActionButton(icon: "plus.circle.fill", title: "Tubo Extra", color: .ballGreen) {
                    withAnimation(.spring(response: 0.3)) {
                        gameViewModel.addEmptyTube()
                    }
                }
            }
            .padding(.bottom, 30)
        }
        .padding(.horizontal)
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
            // Pulsante Home
            Button(action: onMenuTap) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 50, height: 50)

                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 50, height: 50)

                    Image(systemName: "house.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                }
            }
            .shadow(color: .black.opacity(0.3), radius: 5, y: 3)

            Spacer()

            // Info livello
            VStack(spacing: 6) {
                Text("LIVELLO \(level)")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .ballPurple.opacity(0.5), radius: 8)

                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.caption)
                    Text("\(moves) mosse")
                        .font(.subheadline.weight(.medium))
                }
                .foregroundColor(.white.opacity(0.7))
            }

            Spacer()

            // Pulsante Restart
            Button(action: onRestartTap) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 50, height: 50)

                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 50, height: 50)

                    Image(systemName: "arrow.counterclockwise")
                        .font(.title3)
                        .foregroundColor(.white)
                }
            }
            .shadow(color: .black.opacity(0.3), radius: 5, y: 3)
        }
        .padding(.top, 8)
    }
}

struct TubesContainerView: View {
    @ObservedObject var gameViewModel: GameViewModel

    var body: some View {
        let tubes = gameViewModel.gameState.tubes
        let tubeCount = tubes.count

        // Layout adattivo basato sul numero di tubi
        let columns = calculateColumns(for: tubeCount)
        let rows = (tubeCount + columns - 1) / columns

        VStack(spacing: 20) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(0..<columns, id: \.self) { col in
                        let index = row * columns + col
                        if index < tubeCount {
                            TubeView(
                                tube: tubes[index],
                                isSelected: gameViewModel.selectedTubeIndex == index,
                                onTap: {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                        gameViewModel.selectTube(at: index)
                                    }
                                }
                            )
                        } else {
                            // Spazio vuoto per mantenere allineamento
                            Color.clear
                                .frame(width: 70, height: 240)
                        }
                    }
                }
            }
        }
    }

    private func calculateColumns(for count: Int) -> Int {
        switch count {
        case 1...4: return count
        case 5: return 3
        case 6: return 3
        case 7...8: return 4
        case 9: return 5
        case 10...12: return 6
        default: return 6
        }
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    // Glow
                    Circle()
                        .fill(color.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .blur(radius: 10)

                    // Cerchio principale
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .shadow(color: color.opacity(0.5), radius: 8, y: 4)

                    // Highlight
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.4), Color.clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .frame(width: 56, height: 56)

                    Image(systemName: icon)
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2)
                }

                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .scaleEffect(isPressed ? 0.92 : 1.0)
        .animation(.spring(response: 0.2), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

struct WinOverlayView: View {
    let level: Int
    let moves: Int
    let onNextLevel: () -> Void

    @State private var showContent = false
    @State private var showConfetti = false

    var body: some View {
        ZStack {
            // Sfondo scuro
            Color.black.opacity(0.75)
                .ignoresSafeArea()
                .onTapGesture { }

            // Confetti
            if showConfetti {
                ConfettiView()
            }

            VStack(spacing: 35) {
                // Stelle animate
                HStack(spacing: 16) {
                    ForEach(0..<3, id: \.self) { i in
                        StarView(delay: Double(i) * 0.2)
                            .scaleEffect(showContent ? 1 : 0)
                            .animation(
                                .spring(response: 0.6, dampingFraction: 0.5)
                                    .delay(Double(i) * 0.15 + 0.2),
                                value: showContent
                            )
                    }
                }

                // Testo vittoria
                VStack(spacing: 12) {
                    Text("FANTASTICO!")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .ballYellow],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .ballYellow.opacity(0.5), radius: 10)

                    Text("Livello \(level) completato")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.white.opacity(0.9))

                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.ballGreen)
                        Text("\(moves) mosse")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 4)
                }

                // Pulsante prossimo livello
                Button(action: onNextLevel) {
                    HStack(spacing: 12) {
                        Text("Prossimo Livello")
                            .font(.title3.bold())
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title2)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 36)
                    .padding(.vertical, 18)
                    .background(
                        ZStack {
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.ballGreen, Color.ballBlue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )

                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.3), Color.clear],
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                )
                        }
                    )
                    .shadow(color: .ballGreen.opacity(0.6), radius: 15, y: 5)
                }
                .scaleEffect(showContent ? 1 : 0.5)
                .opacity(showContent ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.5), value: showContent)
            }
            .scaleEffect(showContent ? 1 : 0.8)
            .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showContent = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showConfetti = true
            }
        }
    }
}

struct StarView: View {
    let delay: Double
    @State private var isGlowing = false

    var body: some View {
        ZStack {
            // Glow
            Image(systemName: "star.fill")
                .font(.system(size: 55))
                .foregroundColor(.yellow.opacity(0.5))
                .blur(radius: 15)
                .scaleEffect(isGlowing ? 1.3 : 1.0)

            // Stella principale
            Image(systemName: "star.fill")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .orange.opacity(0.8), radius: 8)

            // Highlight
            Image(systemName: "star.fill")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.white.opacity(0.6), Color.clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(delay)) {
                isGlowing = true
            }
        }
    }
}

struct ConfettiView: View {
    let colors: [Color] = [.ballRed, .ballBlue, .ballGreen, .ballYellow, .ballPurple, .orange, .pink]

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<50, id: \.self) { i in
                ConfettiPiece(
                    color: colors[i % colors.count],
                    size: CGFloat.random(in: 6...12),
                    startX: CGFloat.random(in: 0...geo.size.width),
                    delay: Double.random(in: 0...0.5)
                )
            }
        }
        .ignoresSafeArea()
    }
}

struct ConfettiPiece: View {
    let color: Color
    let size: CGFloat
    let startX: CGFloat
    let delay: Double

    @State private var yOffset: CGFloat = -50
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: size, height: size * 0.6)
            .rotationEffect(.degrees(rotation))
            .position(x: startX, y: yOffset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: Double.random(in: 2...4)).delay(delay)) {
                    yOffset = UIScreen.main.bounds.height + 100
                    rotation = Double.random(in: 360...1080)
                }
                withAnimation(.easeIn(duration: 3).delay(delay + 1.5)) {
                    opacity = 0
                }
            }
    }
}

#Preview {
    ZStack {
        AnimatedBackgroundView()
        GameView(gameViewModel: GameViewModel(), showMenu: .constant(false))
    }
}
