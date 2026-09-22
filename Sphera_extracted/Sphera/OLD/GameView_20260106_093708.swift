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

    // FASE 3: Tutorial forme
    @State private var showShapesTutorial: Bool = false
    @AppStorage("shapesTutorialShownForShapeCount") private var tutorialShownForShapeCount: Int = 1

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 12) {
                // Header con safe area
                GameHeaderView(
                    level: gameViewModel.currentLevel,
                    moves: gameViewModel.moves,
                    difficulty: gameViewModel.difficulty,
                    invalidMoves: gameViewModel.invalidMovesCount,
                    maxInvalidMoves: gameViewModel.maxInvalidMoves,
                    formattedTime: gameViewModel.formattedTime,
                    targetTime: gameViewModel.targetTime,
                    elapsedSeconds: gameViewModel.elapsedSeconds,
                    isTimerFrozen: gameViewModel.isTimerFrozen,
                    frozenTimeRemaining: gameViewModel.frozenTimeRemaining,
                    onMenuTap: { showMenu = true },
                    onRestartTap: { gameViewModel.restartLevel() }
                )
                .padding(.top, geometry.safeAreaInsets.top > 20 ? 0 : 8)

                // Power-ups bar (a filo con header)
                PowerUpBarView(gameViewModel: gameViewModel)

                // Area di gioco con i tubi
                TubesContainerView(
                    gameViewModel: gameViewModel,
                    hintSourceIndex: gameViewModel.hintSourceIndex,
                    hintDestIndex: gameViewModel.hintDestIndex,
                    isShowingHint: gameViewModel.isShowingHint
                )
                .padding(.horizontal, 8)

                Spacer(minLength: 8)
            }
            .padding(.horizontal)
        }
        .overlay {
            if gameViewModel.showWinAlert {
                WinOverlayView(
                    level: gameViewModel.currentLevel,
                    moves: gameViewModel.moves,
                    optimalMoves: gameViewModel.lastOptimalMoves,
                    score: gameViewModel.lastScore,
                    stars: gameViewModel.lastStars,
                    elapsedSeconds: gameViewModel.elapsedSeconds,
                    timeBonus: gameViewModel.lastTimeBonus,
                    timeBonusPercentage: gameViewModel.lastTimeBonusPercentage,
                    coinsEarned: gameViewModel.lastCoinsEarned,
                    onNextLevel: {
                        gameViewModel.nextLevel()
                    }
                )
            }

            // Overlay per troppi errori
            if gameViewModel.showTooManyErrorsAlert {
                TooManyErrorsOverlayView(
                    errorCount: gameViewModel.invalidMovesCount,
                    maxErrors: gameViewModel.maxInvalidMoves,
                    difficulty: gameViewModel.difficulty,
                    onRestart: {
                        gameViewModel.confirmRestartAfterErrors()
                    }
                )
            }

            // Overlay per selezione colore (Color Bomb)
            if gameViewModel.isSelectingColorBomb {
                ColorBombSelectionView(gameViewModel: gameViewModel)
                    .transition(.opacity)
            }

            // Overlay per selezione colore (Magic Wand)
            if gameViewModel.isSelectingMagicWand {
                MagicWandSelectionView(gameViewModel: gameViewModel)
                    .transition(.opacity)
            }

            // Avviso: nessun tubo libero per Magic Wand
            if gameViewModel.showMagicWandNoSpaceAlert {
                MagicWandNoSpaceAlert(gameViewModel: gameViewModel)
                    .transition(.opacity)
            }

            // FASE 3: Tutorial forme
            if showShapesTutorial {
                ShapesTutorialView(
                    isPresented: $showShapesTutorial,
                    availableShapes: gameViewModel.currentLevelData?.availableShapes ?? [.ball]
                )
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .onAppear {
            checkShapesTutorial()
        }
        .onChange(of: gameViewModel.currentLevel) { _, _ in
            checkShapesTutorial()
        }
    }

    // FASE 3: Controlla se mostrare il tutorial delle forme
    private func checkShapesTutorial() {
        guard let level = gameViewModel.currentLevelData else { return }

        let currentShapeCount = level.availableShapes.count

        // Mostra tutorial solo se ci sono nuove forme non ancora viste
        if currentShapeCount > tutorialShownForShapeCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showShapesTutorial = true
                }
                tutorialShownForShapeCount = currentShapeCount
            }
        }
    }
}

// MARK: - Game Header

struct GameHeaderView: View {
    let level: Int
    let moves: Int
    let difficulty: Difficulty
    let invalidMoves: Int
    let maxInvalidMoves: Int
    let formattedTime: String
    let targetTime: Int
    let elapsedSeconds: Int
    let isTimerFrozen: Bool
    let frozenTimeRemaining: Int
    let onMenuTap: () -> Void
    let onRestartTap: () -> Void

    private var errorsRemaining: Int {
        max(0, maxInvalidMoves - invalidMoves)
    }

    private var errorColor: Color {
        let ratio = Double(errorsRemaining) / Double(maxInvalidMoves)
        if ratio > 0.5 { return .ballGreen }
        if ratio > 0.2 { return .ballYellow }
        return .ballRed
    }

    private var timerColor: Color {
        let target = Double(targetTime)
        let elapsed = Double(elapsedSeconds)

        if elapsed <= target * 0.5 {
            return .ballGreen      // Molto veloce - bonus 100%
        } else if elapsed <= target {
            return .ballBlue       // Veloce - bonus 50%
        } else if elapsed <= target * 1.5 {
            return .ballYellow     // Normale - bonus 25%
        } else {
            return .white.opacity(0.7)  // Lento - nessun bonus
        }
    }

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

                    Text("\(L10n.level.uppercased()) \(level)")
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

                HStack(spacing: 10) {
                    // Timer (o Freeze indicator)
                    if isTimerFrozen {
                        FreezeTimerIndicator(remainingSeconds: frozenTimeRemaining)
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption)
                            Text(formattedTime)
                                .font(.subheadline.weight(.bold))
                                .monospacedDigit()
                        }
                        .foregroundColor(timerColor)
                    }

                    // Separatore
                    Text("|")
                        .foregroundColor(.white.opacity(0.3))
                        .font(.caption)

                    // Mosse
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.caption)
                        Text("\(moves)")
                            .font(.subheadline.weight(.medium))
                    }
                    .foregroundColor(.white.opacity(0.7))

                    // Separatore
                    Text("|")
                        .foregroundColor(.white.opacity(0.3))
                        .font(.caption)

                    // Errori rimasti
                    HStack(spacing: 4) {
                        Image(systemName: "xmark.circle")
                            .font(.caption)
                        Text("\(errorsRemaining)")
                            .font(.subheadline.weight(.medium))
                    }
                    .foregroundColor(errorColor)
                }
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

        // Controlla se ci sono tubi tall
        let hasTallTube = tubes.contains { $0.type == .tall }

        // Layout adattivo basato sul numero di tubi
        let columns = calculateColumns(for: tubeCount)
        let rows = (tubeCount + columns - 1) / columns

        // Calcola spacing e scala dinamici
        let layoutInfo = calculateLayout(columns: columns, rows: rows, hasTallTube: hasTallTube)

        GeometryReader { geometry in
            let availableWidth = geometry.size.width

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
                                        explodingColor: gameViewModel.isExploding ? gameViewModel.explodingColor : nil,
                                        onTap: {
                                            gameViewModel.selectTube(at: index)
                                        }
                                    )
                                    .scaleEffect(layoutInfo.scale)
                                    .transaction { $0.animation = nil }
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
                .frame(maxWidth: availableWidth)
                .offset(y: hasTallTube ? 10 : 25)
                .transaction { $0.animation = nil }

            }
            .overlay {
                // Pallina volante animata - in overlay per non influenzare layout
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
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .coordinateSpace(name: "tubesContainer")
        }
    }

    private func calculateColumns(for count: Int) -> Int {
        switch count {
        case 1...4: return count
        case 5: return 3
        case 6: return 3
        case 7...8: return 4
        case 9: return 5      // 5 colonne, 2 righe (5+4)
        case 10: return 5     // 5 colonne, 2 righe (5+5)
        default: return 5     // Max 5 colonne per stare in schermo
        }
    }

    // Calcola spacing e scala in base al numero di colonne, righe e numero totale tubi
    // NOTA: Scala quasi invariata, riduco solo lo spacing per avvicinare i tubi
    private func calculateLayout(columns: Int, rows: Int, hasTallTube: Bool) -> (horizontalSpacing: CGFloat, verticalSpacing: CGFloat, scale: CGFloat) {
        let tubeCount = gameViewModel.gameState.tubes.count

        var baseLayout: (horizontalSpacing: CGFloat, verticalSpacing: CGFloat, scale: CGFloat)

        switch columns {
        case 1...3:
            baseLayout = (horizontalSpacing: 8, verticalSpacing: -25, scale: 1.0)
        case 4:
            baseLayout = (horizontalSpacing: -8, verticalSpacing: -30, scale: 0.88)
        case 5:
            // Spacing molto negativo per avvicinare i tubi, scala quasi invariata
            if tubeCount >= 10 {
                baseLayout = (horizontalSpacing: -22, verticalSpacing: -35, scale: 0.82)
            } else if tubeCount >= 9 {
                baseLayout = (horizontalSpacing: -20, verticalSpacing: -35, scale: 0.84)
            } else {
                baseLayout = (horizontalSpacing: -16, verticalSpacing: -35, scale: 0.86)
            }
        default:
            baseLayout = (horizontalSpacing: -24, verticalSpacing: -40, scale: 0.80)
        }

        // Per 2+ righe, riduci leggermente scala e aumenta spacing negativo verticale
        if rows >= 2 {
            let rowScaleFactor: CGFloat
            if hasTallTube {
                rowScaleFactor = tubeCount >= 10 ? 0.78 : 0.82
            } else {
                rowScaleFactor = tubeCount >= 10 ? 0.80 : 0.84
            }
            baseLayout.scale = min(baseLayout.scale, rowScaleFactor)
            baseLayout.verticalSpacing = hasTallTube ? -50 : -40
        }

        return baseLayout
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
            .animation(.easeInOut(duration: 0.35), value: progress)
            .onAppear {
                progress = 1
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
    let optimalMoves: Int
    let score: Int
    let stars: Int
    let elapsedSeconds: Int
    let timeBonus: Int
    let timeBonusPercentage: Int
    let coinsEarned: Int
    let onNextLevel: () -> Void

    @State private var showContent = false
    @State private var showConfetti = false

    private var formattedTime: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private var timeBonusColor: Color {
        switch timeBonusPercentage {
        case 100: return .ballGreen
        case 50: return .ballBlue
        case 25: return .ballYellow
        default: return .white.opacity(0.5)
        }
    }

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

            VStack(spacing: 24) {
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
                    Text(L10n.fantastic)
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .ballYellow],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .ballYellow.opacity(0.5), radius: 10)

                    Text(String(format: L10n.levelCompleted, level))
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.white.opacity(0.9))
                }

                // Stats Grid
                VStack(spacing: 12) {
                    // Prima riga: Tempo
                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.caption)
                            Text(formattedTime)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .monospacedDigit()
                        }
                        .foregroundColor(timeBonusColor)

                        Text(L10n.time)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }

                    // Mosse: Le tue mosse vs Mosse minime
                    HStack(spacing: 20) {
                        // Le tue mosse
                        VStack(spacing: 4) {
                            Text("\(moves)")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(moves <= optimalMoves ? .ballGreen : .white)

                            Text(L10n.yourMoves)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)

                        // VS / separatore
                        Text("vs")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.white.opacity(0.4))

                        // Mosse minime
                        VStack(spacing: 4) {
                            Text("\(optimalMoves)")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.ballBlue)

                            Text(L10n.minMoves)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                    }

                    // Bonus tempo (se presente)
                    if timeBonusPercentage > 0 {
                        HStack(spacing: 6) {
                            Image(systemName: "bolt.fill")
                                .foregroundColor(timeBonusColor)
                            Text("\(L10n.timeBonus): +\(timeBonusPercentage)%")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(timeBonusColor)
                            Text("(+\(timeBonus) \(L10n.points))")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            Capsule()
                                .fill(timeBonusColor.opacity(0.2))
                        )
                    }

                    // Punteggio totale
                    VStack(spacing: 4) {
                        Text("\(score)")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.ballYellow, .orange],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                        Text(L10n.totalScore)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }

                    // Monete guadagnate
                    HStack(spacing: 6) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "F59E0B"))

                        Text("+\(coinsEarned)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "F59E0B"))

                        Text(L10n.coins)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.top, 4)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                )

                // Pulsante prossimo livello
                Button(action: onNextLevel) {
                    HStack(spacing: 12) {
                        Text(L10n.nextLevel)
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

// MARK: - Too Many Errors Overlay

struct TooManyErrorsOverlayView: View {
    let errorCount: Int
    let maxErrors: Int
    let difficulty: Difficulty
    let onRestart: () -> Void

    @State private var showContent = false
    @State private var shakeAnimation = false

    var body: some View {
        ZStack {
            // Sfondo scuro con tinta rossa
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture { }

            VStack(spacing: 24) {
                // Icona animata
                ZStack {
                    Circle()
                        .fill(Color.ballRed.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .blur(radius: 20)

                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 70))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.ballRed, .orange],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .ballRed.opacity(0.6), radius: 15)
                        .rotationEffect(.degrees(shakeAnimation ? -5 : 5))
                }
                .scaleEffect(showContent ? 1 : 0.5)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showContent)

                // Testo
                VStack(spacing: 12) {
                    Text(L10n.tooManyErrors)
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .ballRed.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .ballRed.opacity(0.5), radius: 10)

                    Text(String(format: L10n.youMadeErrors, errorCount))
                        .font(.title3.weight(.medium))
                        .foregroundColor(.white.opacity(0.8))

                    // Badge difficoltà
                    HStack(spacing: 8) {
                        Image(systemName: difficulty.icon)
                            .foregroundColor(difficulty.color)
                        Text(String(format: L10n.errorLimit, maxErrors))
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                    )
                }

                // Messaggio motivazionale
                Text(L10n.dontGiveUp)
                    .font(.callout)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.top, 8)

                // Pulsante restart
                Button(action: onRestart) {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title2)
                        Text(L10n.restart)
                            .font(.title3.bold())
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 36)
                    .padding(.vertical, 18)
                    .background(
                        ZStack {
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.ballRed, Color.orange],
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
                    .shadow(color: .ballRed.opacity(0.6), radius: 15, y: 5)
                }
                .scaleEffect(showContent ? 1 : 0.5)
                .opacity(showContent ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.3), value: showContent)
            }
            .scaleEffect(showContent ? 1 : 0.8)
            .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showContent = true
            }
            // Animazione shake
            withAnimation(.easeInOut(duration: 0.1).repeatCount(6, autoreverses: true)) {
                shakeAnimation = true
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
