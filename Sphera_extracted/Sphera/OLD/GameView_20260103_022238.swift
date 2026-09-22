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
        GeometryReader { geometry in
            VStack(spacing: 12) {
                // Header con safe area
                GameHeaderView(
                    level: gameViewModel.currentLevel,
                    moves: gameViewModel.moves,
                    difficulty: gameViewModel.difficulty,
                    onMenuTap: { showMenu = true },
                    onRestartTap: { gameViewModel.restartLevel() }
                )
                .padding(.top, geometry.safeAreaInsets.top > 20 ? 0 : 8)

                // Area di gioco con i tubi - altezza fissa per evitare spostamenti
                TubesContainerView(
                    gameViewModel: gameViewModel,
                    hintSourceIndex: gameViewModel.hintSourceIndex,
                    hintDestIndex: gameViewModel.hintDestIndex,
                    isShowingHint: gameViewModel.isShowingHint
                )
                .padding(.horizontal, 8)
                .frame(maxHeight: .infinity)

                // Barra azioni: Undo, Hint, Tubo Extra
                // Padding extra per lasciare spazio al banner pubblicitario (50px)
                GameActionsBar(gameViewModel: gameViewModel)
                    .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? 70 : 80)
            }
            .padding(.horizontal)
        }
        .overlay {
            if gameViewModel.showWinAlert {
                WinOverlayView(
                    level: gameViewModel.currentLevel,
                    moves: gameViewModel.moves,
                    score: gameViewModel.lastScore,
                    stars: gameViewModel.lastStars,
                    onNextLevel: {
                        gameViewModel.nextLevel()
                    }
                )
            }
        }
    }
}

// MARK: - Game Actions Bar

struct GameActionsBar: View {
    @ObservedObject var gameViewModel: GameViewModel

    var body: some View {
        HStack(spacing: 16) {
            // Pulsante Undo
            CompactActionButton(
                icon: "arrow.uturn.backward.circle.fill",
                title: "Annulla",
                badge: "\(gameViewModel.undoRemaining)",
                color: .ballBlue,
                isEnabled: gameViewModel.canUndo
            ) {
                withAnimation(.spring(response: 0.3)) {
                    gameViewModel.undo()
                }
            }

            // Pulsante Hint
            CompactActionButton(
                icon: "lightbulb.fill",
                title: "Suggerisci",
                badge: "\(gameViewModel.hintRemaining)",
                color: .ballYellow,
                isEnabled: gameViewModel.canShowHint
            ) {
                withAnimation(.spring(response: 0.3)) {
                    gameViewModel.showHint()
                }
            }

            // Pulsante Tubo Extra (richiede Rewarded Ad)
            CompactActionButton(
                icon: "play.rectangle.fill",
                title: "Tubo +1",
                badge: "AD",
                color: .ballGreen,
                isEnabled: gameViewModel.gameState.tubes.count < 12
            ) {
                AdManager.shared.showRewardedAd(rewardType: .extraTube) { success in
                    if success {
                        withAnimation(.spring(response: 0.3)) {
                            gameViewModel.addEmptyTube()
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Compact Action Button

struct CompactActionButton: View {
    let icon: String
    let title: String
    let badge: String?
    let color: Color
    let isEnabled: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    // Glow
                    Circle()
                        .fill(color.opacity(isEnabled ? 0.3 : 0.1))
                        .frame(width: 56, height: 56)
                        .blur(radius: 8)

                    // Cerchio principale
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: isEnabled
                                    ? [color, color.opacity(0.7)]
                                    : [Color.gray.opacity(0.5), Color.gray.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)
                        .shadow(color: isEnabled ? color.opacity(0.5) : .clear, radius: 6, y: 3)

                    // Highlight
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.4), Color.clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .frame(width: 52, height: 52)

                    Image(systemName: icon)
                        .font(.title2.weight(.semibold))
                        .foregroundColor(isEnabled ? .white : .white.opacity(0.5))
                        .shadow(color: .black.opacity(0.3), radius: 2)

                    // Badge
                    if let badge = badge {
                        Text(badge)
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(isEnabled ? Color.black.opacity(0.6) : Color.black.opacity(0.3))
                            )
                            .offset(x: 18, y: -18)
                    }
                }

                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundColor(isEnabled ? .white.opacity(0.9) : .white.opacity(0.4))
            }
        }
        .disabled(!isEnabled)
        .scaleEffect(isPressed ? 0.92 : 1.0)
        .animation(.spring(response: 0.2), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in if isEnabled { isPressed = true } }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Game Header

struct GameHeaderView: View {
    let level: Int
    let moves: Int
    let difficulty: Difficulty
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
                HStack(spacing: 8) {
                    Image(systemName: difficulty.icon)
                        .foregroundColor(difficulty.color)
                        .font(.caption)

                    Text("LIVELLO \(level)")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
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

// MARK: - Tubes Container

struct TubesContainerView: View {
    @ObservedObject var gameViewModel: GameViewModel
    let hintSourceIndex: Int?
    let hintDestIndex: Int?
    let isShowingHint: Bool

    // Per tracciare posizioni tubi
    @State private var tubePositions: [Int: CGPoint] = [:]

    var body: some View {
        let tubes = gameViewModel.gameState.tubes
        let tubeCount = tubes.count

        // Layout adattivo basato sul numero di tubi
        let columns = calculateColumns(for: tubeCount)
        let rows = (tubeCount + columns - 1) / columns

        // Calcola spacing e scala dinamici
        let layoutInfo = calculateLayout(columns: columns)

        ZStack {
            VStack(spacing: layoutInfo.verticalSpacing) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: layoutInfo.horizontalSpacing) {
                        ForEach(0..<columns, id: \.self) { col in
                            let index = row * columns + col
                            if index < tubeCount {
                                TubeView(
                                    tube: tubes[index],
                                    isSelected: gameViewModel.selectedTubeIndex == index,
                                    isHintSource: isShowingHint && hintSourceIndex == index,
                                    isHintDest: isShowingHint && hintDestIndex == index,
                                    isAnimatingSource: gameViewModel.isAnimating && gameViewModel.animationFromIndex == index,
                                    onTap: {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                            gameViewModel.selectTube(at: index)
                                        }
                                    }
                                )
                                .scaleEffect(layoutInfo.scale)
                                .background(
                                    GeometryReader { geo in
                                        Color.clear
                                            .onAppear {
                                                let frame = geo.frame(in: .named("tubesContainer"))
                                                tubePositions[index] = CGPoint(x: frame.midX, y: frame.minY + 30 * layoutInfo.scale)
                                            }
                                            .onChange(of: geo.frame(in: .named("tubesContainer"))) { _, newFrame in
                                                tubePositions[index] = CGPoint(x: newFrame.midX, y: newFrame.minY + 30 * layoutInfo.scale)
                                            }
                                    }
                                )
                            } else {
                                // Spazio vuoto per mantenere allineamento
                                Color.clear
                                    .frame(width: 88 * layoutInfo.scale, height: 250 * layoutInfo.scale)
                            }
                        }
                    }
                }
            }

            // Pallina volante animata
            if gameViewModel.isAnimating,
               let ball = gameViewModel.animatingBall,
               let fromIndex = gameViewModel.animationFromIndex,
               let toIndex = gameViewModel.animationToIndex,
               let fromPos = tubePositions[fromIndex],
               let toPos = tubePositions[toIndex] {
                FlyingBallView(
                    ball: ball,
                    fromPosition: fromPos,
                    toPosition: toPos
                )
            }
        }
        .coordinateSpace(name: "tubesContainer")
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

    // Calcola spacing e scala in base al numero di colonne
    private func calculateLayout(columns: Int) -> (horizontalSpacing: CGFloat, verticalSpacing: CGFloat, scale: CGFloat) {
        switch columns {
        case 1...3:
            return (horizontalSpacing: 12, verticalSpacing: 20, scale: 1.0)
        case 4:
            return (horizontalSpacing: 6, verticalSpacing: 16, scale: 0.95)
        case 5:
            return (horizontalSpacing: 2, verticalSpacing: 14, scale: 0.85)
        case 6:
            return (horizontalSpacing: -2, verticalSpacing: 12, scale: 0.78)
        default:
            return (horizontalSpacing: -4, verticalSpacing: 10, scale: 0.72)
        }
    }
}

// MARK: - Flying Ball Animation

struct FlyingBallView: View {
    let ball: Ball
    let fromPosition: CGPoint
    let toPosition: CGPoint

    @State private var progress: CGFloat = 0

    var body: some View {
        BallView(ball: ball, size: 44, isTopBall: false)
            .position(currentPosition)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.35)) {
                    progress = 1
                }
            }
    }

    private var currentPosition: CGPoint {
        // Curva Bezier quadratica per traiettoria ad arco
        let controlY = min(fromPosition.y, toPosition.y) - 80

        let t = progress
        let oneMinusT = 1 - t

        // P0 = fromPosition, P1 = control point (in alto), P2 = toPosition
        let controlPoint = CGPoint(
            x: (fromPosition.x + toPosition.x) / 2,
            y: controlY
        )

        let x = oneMinusT * oneMinusT * fromPosition.x +
                2 * oneMinusT * t * controlPoint.x +
                t * t * toPosition.x

        let y = oneMinusT * oneMinusT * fromPosition.y +
                2 * oneMinusT * t * controlPoint.y +
                t * t * toPosition.y

        return CGPoint(x: x, y: y)
    }
}

// MARK: - Action Button (legacy, kept for compatibility)

struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    // Glow
                    Circle()
                        .fill(color.opacity(0.3))
                        .frame(width: 50, height: 50)
                        .blur(radius: 8)

                    // Cerchio principale
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 46, height: 46)
                        .shadow(color: color.opacity(0.5), radius: 6, y: 3)

                    // Highlight
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.4), Color.clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .frame(width: 46, height: 46)

                    Image(systemName: icon)
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2)
                }

                Text(title)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        Capsule()
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.2), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Win Overlay

struct WinOverlayView: View {
    let level: Int
    let moves: Int
    let score: Int
    let stars: Int
    let onNextLevel: () -> Void

    @State private var showContent = false
    @State private var showConfetti = false

    var body: some View {
        ZStack {
            // Sfondo scuro
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture { }

            // Confetti
            if showConfetti {
                ConfettiView()
            }

            VStack(spacing: 28) {
                // Stelle animate
                HStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { i in
                        StarView(delay: Double(i) * 0.2, isFilled: i < stars)
                            .scaleEffect(showContent ? 1 : 0)
                            .animation(
                                .spring(response: 0.6, dampingFraction: 0.5)
                                    .delay(Double(i) * 0.15 + 0.2),
                                value: showContent
                            )
                    }
                }

                // Testo vittoria
                VStack(spacing: 10) {
                    Text("FANTASTICO!")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .ballYellow],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .ballYellow.opacity(0.5), radius: 10)

                    Text("Livello \(level) completato")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.white.opacity(0.9))
                }

                // Score e mosse
                HStack(spacing: 30) {
                    VStack(spacing: 4) {
                        Text("\(moves)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("Mosse")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }

                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 1, height: 50)

                    VStack(spacing: 4) {
                        Text("\(score)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.ballYellow, .orange],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                        Text("Punti")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 30)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                )

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

// MARK: - Star View

struct StarView: View {
    let delay: Double
    let isFilled: Bool
    @State private var isGlowing = false

    var body: some View {
        ZStack {
            if isFilled {
                // Glow
                Image(systemName: "star.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.yellow.opacity(0.5))
                    .blur(radius: 15)
                    .scaleEffect(isGlowing ? 1.3 : 1.0)

                // Stella principale
                Image(systemName: "star.fill")
                    .font(.system(size: 45))
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
                    .font(.system(size: 45))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white.opacity(0.6), Color.clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
            } else {
                // Stella vuota
                Image(systemName: "star")
                    .font(.system(size: 45))
                    .foregroundColor(.white.opacity(0.3))
            }
        }
        .onAppear {
            if isFilled {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(delay)) {
                    isGlowing = true
                }
            }
        }
    }
}

// MARK: - Confetti

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
