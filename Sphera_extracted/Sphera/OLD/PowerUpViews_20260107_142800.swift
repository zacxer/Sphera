//
//  PowerUpViews.swift
//  BallSortPuzzle
//
//  Created on 2026-01-03.
//

import SwiftUI

// MARK: - Power-up Bar View

struct PowerUpBarView: View {
    @ObservedObject var gameViewModel: GameViewModel
    @ObservedObject var settings = SettingsManager.shared
    @State private var showShop = false

    // Costi azioni
    private let undoCost = 10
    private let hintCost = 15
    private let tubeCost = 20

    // Controlla se ha usi gratuiti
    private var hasUndoFree: Bool { gameViewModel.undoRemaining > 0 }
    private var hasHintFree: Bool { gameViewModel.hintRemaining > 0 }

    // Può usare (gratis o pagando)
    private var canUseUndo: Bool {
        gameViewModel.canUndo || settings.coins >= undoCost
    }
    private var canUseHint: Bool {
        gameViewModel.canShowHint || settings.coins >= hintCost
    }
    private var canUseTube: Bool {
        gameViewModel.canAddExtraTube && settings.coins >= tubeCost
    }

    var body: some View {
        VStack(spacing: 4) {
            // Riga unica compatta: Monete + AD | Undo, Hint, Tubo | Power-ups
            HStack(spacing: 3) {
                // Monete + bottone AD
                HStack(spacing: 2) {
                    CoinDisplayView(coins: settings.coins)
                        .onTapGesture {
                            showShop = true
                        }

                    // SCREENSHOT: Bottone AD commentato per screenshot App Store
                    /*
                    Button(action: {
                        AdManager.shared.showRewardedAd(rewardType: .coins) { success in
                            if success {
                                settings.addCoins(25)
                            }
                        }
                    }) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "22C55E"))
                    }
                    */
                }

                // Separatore
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 1, height: 20)

                // Undo
                ActionMiniButton(
                    icon: "arrow.uturn.backward",
                    badge: hasUndoFree ? "\(gameViewModel.undoRemaining)" : "\(undoCost)",
                    color: .ballBlue,
                    isEnabled: canUseUndo
                ) {
                    if hasUndoFree {
                        gameViewModel.undo()
                    } else if settings.coins >= undoCost {
                        settings.coins -= undoCost
                        gameViewModel.addExtraUndo(count: 1)
                        gameViewModel.undo()
                    }
                }

                // Hint
                ActionMiniButton(
                    icon: "lightbulb.fill",
                    badge: hasHintFree ? "\(gameViewModel.hintRemaining)" : "\(hintCost)",
                    color: .ballYellow,
                    isEnabled: canUseHint
                ) {
                    if hasHintFree {
                        gameViewModel.showHint()
                    } else if settings.coins >= hintCost {
                        settings.coins -= hintCost
                        gameViewModel.addExtraHints(count: 1)
                        gameViewModel.showHint()
                    }
                }

                // Tubo Extra
                ActionMiniButton(
                    icon: "plus.circle.fill",
                    badge: "\(tubeCost)",
                    color: .ballGreen,
                    isEnabled: canUseTube
                ) {
                    if settings.coins >= tubeCost {
                        settings.coins -= tubeCost
                        gameViewModel.addEmptyTube()
                    }
                }

                // Separatore
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 1, height: 20)

                // Power-ups
                ForEach(PowerUpType.allCases, id: \.self) { type in
                    PowerUpButton(
                        type: type,
                        coins: settings.coins,
                        isDisabled: !gameViewModel.canUsePowerUp(type)
                    ) {
                        gameViewModel.usePowerUp(type)
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.35))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .sheet(isPresented: $showShop) {
            PowerUpShopView(settings: settings)
        }
    }
}

// MARK: - Action Mini Button (Undo, Hint, ExtraTube)

struct ActionMiniButton: View {
    let icon: String
    let badge: String
    let color: Color
    let isEnabled: Bool
    let action: () -> Void

    // Badge con $ = colore monete, altrimenti colore del bottone
    private var badgeColor: Color {
        if badge.contains("$") {
            return Color(hex: "F59E0B")  // Colore monete
        }
        return color
    }

    var body: some View {
        Button(action: {
            if isEnabled { action() }
        }) {
            ZStack {
                Circle()
                    .fill(isEnabled ? color.opacity(0.3) : Color.gray.opacity(0.2))
                    .frame(width: 28, height: 28)

                Circle()
                    .stroke(isEnabled ? color : Color.gray.opacity(0.4), lineWidth: 1)
                    .frame(width: 28, height: 28)

                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(isEnabled ? color : .gray)

                // Badge
                Text(badge)
                    .font(.system(size: 6, weight: .bold))
                    .foregroundColor(.white)
                    .padding(2)
                    .background(Circle().fill(badgeColor))
                    .offset(x: 10, y: -10)
            }
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.5)
    }
}

// MARK: - Coin Display

struct CoinDisplayView: View {
    let coins: Int

    @State private var isPulsing: Bool = false
    @State private var glowOpacity: Double = 0

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "F59E0B"))

            Text("\(coins)")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color(hex: "F59E0B").opacity(0.2))
        )
        .overlay(
            Capsule()
                .stroke(Color(hex: "FFD700"), lineWidth: 2)
                .opacity(glowOpacity)
                .blur(radius: 2)
        )
        .scaleEffect(isPulsing ? 1.08 : 1.0)
        .shadow(color: Color(hex: "FFD700").opacity(glowOpacity * 0.8), radius: 8)
        .onAppear {
            startPulseTimer()
        }
    }

    private func startPulseTimer() {
        // Pulse ogni 3 secondi
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                isPulsing = true
                glowOpacity = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isPulsing = false
                    glowOpacity = 0
                }
            }
        }
    }
}

// MARK: - Power-up Button

struct PowerUpButton: View {
    let type: PowerUpType
    let coins: Int
    let isDisabled: Bool
    let action: () -> Void

    // Può usare se ha abbastanza monete
    private var canUse: Bool {
        coins >= type.cost
    }

    var body: some View {
        Button(action: {
            if canUse {
                action()
            }
        }) {
            ZStack {
                // Background
                Circle()
                    .fill(
                        canUse
                            ? type.color.opacity(0.3)
                            : Color.gray.opacity(0.3)
                    )
                    .frame(width: 28, height: 28)

                // Border
                Circle()
                    .stroke(
                        canUse
                            ? type.color
                            : Color.gray.opacity(0.5),
                        lineWidth: 1
                    )
                    .frame(width: 28, height: 28)

                // Icon
                Image(systemName: type.icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(canUse ? type.color : .gray)

                // Costo badge
                Text("\(type.cost)")
                    .font(.system(size: 5, weight: .bold))
                    .foregroundColor(.white)
                    .padding(2)
                    .background(Circle().fill(Color(hex: "F59E0B")))
                    .offset(x: 10, y: -10)
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(!canUse || isDisabled)
        .opacity(canUse && !isDisabled ? 1 : 0.5)
    }
}

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Color Bomb Selection View

struct ColorBombSelectionView: View {
    @ObservedObject var gameViewModel: GameViewModel

    var body: some View {
        ZStack {
            // Dim background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    gameViewModel.cancelColorBombSelection()
                }

            VStack(spacing: 20) {
                // Title
                Text(L10n.selectColor)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                // Color grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(gameViewModel.availableColorsForBomb, id: \.self) { color in
                        ColorBombColorButton(color: color) {
                            gameViewModel.selectColorForBomb(color)
                        }
                    }
                }
                .padding()

                // Cancel button
                Button(action: {
                    gameViewModel.cancelColorBombSelection()
                }) {
                    Text(L10n.cancel)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(hex: "1A1A2E"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color(hex: "EF4444").opacity(0.5), lineWidth: 2)
                    )
            )
            .padding(40)
        }
    }
}

struct ColorBombColorButton: View {
    let color: BallColor
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                // Usa la vera pallina (BallView) con effetto 3D
                BallView(
                    ball: Ball(color: color, shape: .ball),
                    size: 56,
                    isTopBall: false
                )

                // Icona bomba sovrapposta
                Image(systemName: "flame.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.5), radius: 2)
            }
            .shadow(color: color.color.opacity(0.6), radius: 10)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Magic Wand Selection View

struct MagicWandSelectionView: View {
    @ObservedObject var gameViewModel: GameViewModel

    var body: some View {
        ZStack {
            // Dim background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    gameViewModel.cancelMagicWandSelection()
                }

            VStack(spacing: 20) {
                // Icon
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 40))
                    .foregroundColor(Color(hex: "A855F7"))
                    .shadow(color: Color(hex: "A855F7").opacity(0.6), radius: 12)

                // Title
                Text(L10n.chooseColorComplete)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                // Subtitle
                Text(L10n.wandWillComplete)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)

                // Color grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(gameViewModel.availableColorsForMagicWand, id: \.self) { color in
                        MagicWandColorButton(color: color) {
                            gameViewModel.selectColorForMagicWand(color)
                        }
                    }
                }
                .padding()

                // Cancel button
                Button(action: {
                    gameViewModel.cancelMagicWandSelection()
                }) {
                    Text(L10n.cancel)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(hex: "1A1A2E"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color(hex: "A855F7").opacity(0.5), lineWidth: 2)
                    )
            )
            .padding(40)
        }
    }
}

struct MagicWandColorButton: View {
    let color: BallColor
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                // Usa la vera pallina (BallView) con effetto 3D
                BallView(
                    ball: Ball(color: color, shape: .ball),
                    size: 56,
                    isTopBall: false
                )

                // Sparkle overlay (bacchetta magica)
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.5), radius: 2)
            }
            .shadow(color: color.color.opacity(0.6), radius: 10)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Magic Wand No Space Alert

struct MagicWandNoSpaceAlert: View {
    @ObservedObject var gameViewModel: GameViewModel

    var body: some View {
        ZStack {
            // Dim background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    gameViewModel.showMagicWandNoSpaceAlert = false
                }

            VStack(spacing: 20) {
                // Icon
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(Color(hex: "F59E0B"))
                    .shadow(color: Color(hex: "F59E0B").opacity(0.6), radius: 12)

                // Title
                Text(L10n.magicWandNoSpace)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                // Description
                Text(L10n.magicWandNoSpaceDesc)
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)

                // OK Button
                Button(action: {
                    gameViewModel.showMagicWandNoSpaceAlert = false
                }) {
                    Text("OK")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 50)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .fill(Color(hex: "F59E0B"))
                        )
                        .shadow(color: Color(hex: "F59E0B").opacity(0.5), radius: 8)
                }
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(hex: "1A1A2E"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color(hex: "F59E0B").opacity(0.5), lineWidth: 2)
                    )
            )
            .padding(40)
        }
    }
}

// MARK: - Power-up Visual Effects

/// Effetto Freeze Timer - Solo bordi e fiocchi ai lati (NON copre il gioco)
struct FreezeTimerEffectView: View {
    @State private var snowflakeOffsets: [CGSize] = (0..<12).map { _ in
        CGSize(width: CGFloat.random(in: -200...200), height: -50)
    }
    @State private var borderPulse: Bool = false
    @State private var leftSnowflakes: [CGFloat] = (0..<6).map { _ in CGFloat.random(in: -50...0) }
    @State private var rightSnowflakes: [CGFloat] = (0..<6).map { _ in CGFloat.random(in: -50...0) }

    var body: some View {
        ZStack {
            // Bordi ghiacciati SOLO AI LATI (non coprono il centro)
            HStack {
                // Bordo sinistro ghiacciato
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.cyan.opacity(0.5), Color.cyan.opacity(0.2), Color.clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: borderPulse ? 40 : 25)

                Spacer()

                // Bordo destro ghiacciato
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.clear, Color.cyan.opacity(0.2), Color.cyan.opacity(0.5)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: borderPulse ? 40 : 25)
            }
            .ignoresSafeArea()

            // Fiocchi di neve SOLO sui bordi sinistro e destro
            ForEach(0..<6, id: \.self) { i in
                // Fiocco sinistro
                Image(systemName: "snowflake")
                    .font(.system(size: CGFloat.random(in: 12...20)))
                    .foregroundColor(.white.opacity(0.8))
                    .shadow(color: .cyan, radius: 3)
                    .position(x: 20, y: leftSnowflakes[i])

                // Fiocco destro
                Image(systemName: "snowflake")
                    .font(.system(size: CGFloat.random(in: 12...20)))
                    .foregroundColor(.white.opacity(0.8))
                    .shadow(color: .cyan, radius: 3)
                    .position(x: UIScreen.main.bounds.width - 20, y: rightSnowflakes[i])
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                borderPulse = true
            }
            // Animazione fiocchi laterali
            for i in 0..<6 {
                withAnimation(
                    .linear(duration: Double.random(in: 4...8))
                    .repeatForever(autoreverses: false)
                    .delay(Double.random(in: 0...3))
                ) {
                    leftSnowflakes[i] = UIScreen.main.bounds.height + 50
                    rightSnowflakes[i] = UIScreen.main.bounds.height + 50
                }
            }
        }
    }
}

/// Effetto Shuffle - Vortice GRANDE E VISIBILE
struct ShuffleEffectView: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0
    @State private var flashOpacity: Double = 0

    var body: some View {
        ZStack {
            // Flash bianco iniziale
            Color.white
                .opacity(flashOpacity)
                .ignoresSafeArea()

            // Sfondo scuro
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            // Vortice GRANDE
            ZStack {
                // Cerchi rotanti
                ForEach(0..<5, id: \.self) { i in
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [.orange, .yellow, .red, .orange.opacity(0)],
                                center: .center
                            ),
                            lineWidth: 12 - CGFloat(i * 2)
                        )
                        .frame(width: 120 + CGFloat(i * 70), height: 120 + CGFloat(i * 70))
                        .rotationEffect(.degrees(rotation + Double(i * 45)))
                        .shadow(color: .orange, radius: 10)
                }

                // Palline che volano nel vortice
                ForEach(0..<8, id: \.self) { i in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.white, [Color.red, .blue, .green, .yellow, .purple, .orange, .pink, .cyan][i]],
                                center: .center,
                                startRadius: 0,
                                endRadius: 15
                            )
                        )
                        .frame(width: 30, height: 30)
                        .offset(x: 100)
                        .rotationEffect(.degrees(rotation * 2 + Double(i * 45)))
                        .shadow(color: .white, radius: 5)
                }

                // Icona centrale
                Image(systemName: "shuffle")
                    .font(.system(size: 70, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .orange, radius: 20)
                    .scaleEffect(scale > 0.8 ? 1.2 : 1.0)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .allowsHitTesting(false)
        .onAppear {
            // Flash iniziale
            withAnimation(.easeOut(duration: 0.15)) {
                flashOpacity = 0.8
            }
            withAnimation(.easeIn(duration: 0.2).delay(0.15)) {
                flashOpacity = 0
            }
            // Scala e opacità
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
            // Rotazione continua
            withAnimation(.linear(duration: 0.5).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

/// Effetto Undo All - Onde rewind GRANDI
struct UndoAllEffectView: View {
    @State private var waveScale: [CGFloat] = [0.2, 0.2, 0.2, 0.2, 0.2]
    @State private var waveOpacity: [Double] = [1, 1, 1, 1, 1]
    @State private var arrowRotation: Double = 0
    @State private var arrowScale: CGFloat = 0.5
    @State private var flashOpacity: Double = 0

    var body: some View {
        ZStack {
            // Flash viola
            Color(hex: "8B5CF6")
                .opacity(flashOpacity)
                .ignoresSafeArea()

            // Sfondo scuro
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            // Onde circolari GRANDI
            ForEach(0..<5, id: \.self) { i in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "8B5CF6"), Color(hex: "A855F7"), Color(hex: "8B5CF6").opacity(0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 6 - CGFloat(i)
                    )
                    .frame(width: 80, height: 80)
                    .scaleEffect(waveScale[i])
                    .opacity(waveOpacity[i])
            }

            // Icona rewind GRANDE
            VStack(spacing: 10) {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "A855F7"), Color(hex: "8B5CF6")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .rotationEffect(.degrees(arrowRotation))
                    .scaleEffect(arrowScale)
                    .shadow(color: Color(hex: "8B5CF6"), radius: 30)

                Text("RICOMINCIA")
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(.white)
                    .opacity(arrowScale > 0.8 ? 1 : 0)
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            // Flash iniziale
            withAnimation(.easeOut(duration: 0.1)) {
                flashOpacity = 0.6
            }
            withAnimation(.easeIn(duration: 0.2).delay(0.1)) {
                flashOpacity = 0
            }
            // Onde che si espandono
            for i in 0..<5 {
                withAnimation(.easeOut(duration: 0.8).delay(Double(i) * 0.1)) {
                    waveScale[i] = 5.0
                    waveOpacity[i] = 0
                }
            }
            // Freccia
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                arrowScale = 1.0
            }
            withAnimation(.easeInOut(duration: 0.6)) {
                arrowRotation = -720
            }
        }
    }
}

/// Effetto Magic Wand - Sparkles GRANDI e VISIBILI
struct MagicWandEffectView: View {
    @State private var wandScale: CGFloat = 0.3
    @State private var wandRotation: Double = -30
    @State private var sparkleOpacity: Double = 0
    @State private var starsOffset: [CGSize] = (0..<30).map { _ in .zero }
    @State private var starsOpacity: [Double] = Array(repeating: 0, count: 30)
    @State private var starsScale: [CGFloat] = Array(repeating: 0.3, count: 30)
    @State private var glowPulse: Bool = false
    @State private var flashOpacity: Double = 0

    var body: some View {
        ZStack {
            // Flash dorato
            Color(hex: "FFD700")
                .opacity(flashOpacity)
                .ignoresSafeArea()

            // Sfondo dorato
            Color(hex: "F59E0B").opacity(0.2)
                .ignoresSafeArea()

            // Raggi di luce dal centro
            ForEach(0..<12, id: \.self) { i in
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "FFD700").opacity(0.8), Color.clear],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 8, height: 400)
                    .offset(y: 200)
                    .rotationEffect(.degrees(Double(i) * 30))
                    .opacity(glowPulse ? 0.6 : 0.3)
            }

            // Stelle che esplodono
            ForEach(0..<30, id: \.self) { i in
                Image(systemName: ["star.fill", "sparkle", "star.fill"][i % 3])
                    .font(.system(size: CGFloat.random(in: 20...40)))
                    .foregroundColor([Color(hex: "FFD700"), .white, Color(hex: "FFA500")][i % 3])
                    .offset(starsOffset[i])
                    .opacity(starsOpacity[i])
                    .scaleEffect(starsScale[i])
                    .shadow(color: Color(hex: "FFD700"), radius: 10)
            }

            // Bacchetta centrale GRANDE
            VStack(spacing: 15) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 100))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "FFD700"), Color(hex: "FFA500"), Color(hex: "FFD700")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .rotationEffect(.degrees(wandRotation))
                    .scaleEffect(wandScale)
                    .shadow(color: Color(hex: "FFD700"), radius: glowPulse ? 40 : 20)

                Text("MAGIA!")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(Color(hex: "FFD700"))
                    .shadow(color: .black, radius: 2)
                    .opacity(wandScale > 0.8 ? 1 : 0)
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            // Flash iniziale
            withAnimation(.easeOut(duration: 0.1)) {
                flashOpacity = 0.7
            }
            withAnimation(.easeIn(duration: 0.2).delay(0.1)) {
                flashOpacity = 0
            }
            // Bacchetta
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                wandScale = 1.0
                wandRotation = 15
            }
            // Glow pulsante
            withAnimation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
            // Stelle che esplodono dal centro
            for i in 0..<30 {
                let angle = Double(i) * (360.0 / 30.0) * .pi / 180.0
                let distance = CGFloat.random(in: 150...350)
                withAnimation(.easeOut(duration: 0.6).delay(Double.random(in: 0...0.2))) {
                    starsOffset[i] = CGSize(
                        width: cos(angle) * distance,
                        height: sin(angle) * distance
                    )
                    starsOpacity[i] = 1
                    starsScale[i] = CGFloat.random(in: 1.0...1.5)
                }
                withAnimation(.easeIn(duration: 0.3).delay(0.5)) {
                    starsOpacity[i] = 0
                }
            }
        }
    }
}

/// Effetto Color Bomb - ESPLOSIONE GRANDE
struct ColorBombEffectView: View {
    let color: Color

    @State private var ringScale: [CGFloat] = [0.2, 0.2, 0.2]
    @State private var ringOpacity: [Double] = [1, 1, 1]
    @State private var particleOffsets: [CGSize] = (0..<24).map { _ in .zero }
    @State private var particleOpacity: [Double] = Array(repeating: 1, count: 24)
    @State private var particleScale: [CGFloat] = Array(repeating: 1, count: 24)
    @State private var flashOpacity: Double = 0
    @State private var bombScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Flash del colore
            color
                .opacity(flashOpacity)
                .ignoresSafeArea()

            // Sfondo scuro
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            // Anelli esplosivi
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .stroke(color, lineWidth: 8 - CGFloat(i * 2))
                    .frame(width: 100, height: 100)
                    .scaleEffect(ringScale[i])
                    .opacity(ringOpacity[i])
            }

            // Particelle che esplodono
            ForEach(0..<24, id: \.self) { i in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.white, color],
                            center: .center,
                            startRadius: 0,
                            endRadius: 15
                        )
                    )
                    .frame(width: 25, height: 25)
                    .offset(particleOffsets[i])
                    .opacity(particleOpacity[i])
                    .scaleEffect(particleScale[i])
                    .shadow(color: color, radius: 8)
            }

            // Icona bomba centrale
            VStack(spacing: 10) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 80))
                    .foregroundColor(color)
                    .scaleEffect(bombScale)
                    .shadow(color: color, radius: 30)

                Text("BOOM!")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.white)
                    .shadow(color: color, radius: 10)
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            // Flash iniziale
            withAnimation(.easeOut(duration: 0.1)) {
                flashOpacity = 0.8
            }
            withAnimation(.easeIn(duration: 0.15).delay(0.1)) {
                flashOpacity = 0
            }
            // Bomba che pulsa
            withAnimation(.easeInOut(duration: 0.15).repeatCount(3, autoreverses: true)) {
                bombScale = 1.3
            }
            // Anelli esplosivi
            for i in 0..<3 {
                withAnimation(.easeOut(duration: 0.5).delay(Double(i) * 0.1)) {
                    ringScale[i] = 6.0
                    ringOpacity[i] = 0
                }
            }
            // Particelle che esplodono
            for i in 0..<24 {
                let angle = Double(i) * (360.0 / 24.0) * .pi / 180.0
                let distance = CGFloat.random(in: 200...400)
                withAnimation(.easeOut(duration: 0.5)) {
                    particleOffsets[i] = CGSize(
                        width: cos(angle) * distance,
                        height: sin(angle) * distance
                    )
                }
                withAnimation(.easeIn(duration: 0.2).delay(0.4)) {
                    particleOpacity[i] = 0
                    particleScale[i] = 0.3
                }
            }
        }
    }
}

// MARK: - Power-up Shop View

struct PowerUpShopView: View {
    @ObservedObject var settings: SettingsManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color(hex: "0F0C29"), Color(hex: "302B63"), Color(hex: "24243E")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Coins header + Watch AD button
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(Color(hex: "F59E0B"))

                                Text("\(settings.coins)")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)

                                Text(L10n.coins)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                            }

                            // SCREENSHOT: Watch AD button commentato per screenshot App Store
                            /*
                            Button(action: {
                                AdManager.shared.showRewardedAd(rewardType: .coins) { success in
                                    if success {
                                        settings.addCoins(25)
                                    }
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "play.rectangle.fill")
                                        .font(.system(size: 18))
                                    Text(L10n.current == .italian ? "Guarda AD +25" : "Watch AD +25")
                                        .font(.system(size: 16, weight: .bold))
                                    Image(systemName: "dollarsign.circle.fill")
                                        .font(.system(size: 16))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(hex: "22C55E"), Color(hex: "16A34A")],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                                .shadow(color: Color(hex: "22C55E").opacity(0.4), radius: 8, y: 4)
                            }
                            */
                        }
                        .padding(.vertical, 20)

                        // MARK: - Sezione Azioni
                        VStack(alignment: .leading, spacing: 12) {
                            Text(L10n.shopActions)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.leading, 8)

                            // Undo
                            ActionShopItem(
                                icon: "arrow.uturn.backward",
                                name: L10n.undo,
                                description: L10n.undoDesc,
                                cost: 10,
                                color: .ballBlue
                            )

                            // Hint
                            ActionShopItem(
                                icon: "lightbulb.fill",
                                name: L10n.hint,
                                description: L10n.hintDesc,
                                cost: 15,
                                color: .ballYellow
                            )

                            // Extra Tube
                            ActionShopItem(
                                icon: "plus.circle.fill",
                                name: L10n.extraTube,
                                description: L10n.extraTubeDesc,
                                cost: 20,
                                color: .ballGreen
                            )
                        }

                        // MARK: - Sezione Power-ups
                        VStack(alignment: .leading, spacing: 12) {
                            Text(L10n.powerUps)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.leading, 8)

                            ForEach(PowerUpType.allCases, id: \.self) { type in
                                PowerUpShopItem(type: type)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(L10n.current == .italian ? "Negozio" : "Shop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L10n.done) {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "A855F7"))
                }
            }
        }
    }
}

// MARK: - Action Shop Item (Undo, Hint, ExtraTube)

struct ActionShopItem: View {
    let icon: String
    let name: String
    let description: String
    let cost: Int
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 56, height: 56)

                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)

                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(2)
            }

            Spacer()

            // Cost indicator (non acquistabile, solo info costo)
            HStack(spacing: 4) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 14))
                Text("\(cost)")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(Color(hex: "F59E0B"))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color(hex: "F59E0B").opacity(0.15))
                    .overlay(
                        Capsule()
                            .stroke(Color(hex: "F59E0B").opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct PowerUpShopItem: View {
    let type: PowerUpType

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(type.color.opacity(0.2))
                    .frame(width: 56, height: 56)

                Image(systemName: type.icon)
                    .font(.system(size: 24))
                    .foregroundColor(type.color)
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(type.displayName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)

                Text(type.description)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(2)
            }

            Spacer()

            // Costo (solo info, non comprabile qui)
            HStack(spacing: 4) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 14))
                Text("\(type.cost)")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(Color(hex: "F59E0B"))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color(hex: "F59E0B").opacity(0.15))
                    .overlay(
                        Capsule()
                            .stroke(Color(hex: "F59E0B").opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(type.color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Freeze Timer Indicator

struct FreezeTimerIndicator: View {
    let remainingSeconds: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "snowflake")
                .font(.system(size: 14, weight: .bold))

            Text("\(remainingSeconds)s")
                .font(.system(size: 14, weight: .bold, design: .rounded))
        }
        .foregroundColor(Color(hex: "06B6D4"))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color(hex: "06B6D4").opacity(0.2))
                .overlay(
                    Capsule()
                        .stroke(Color(hex: "06B6D4"), lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(hex: "1A1A2E").ignoresSafeArea()

        VStack {
            PowerUpBarView(gameViewModel: GameViewModel())
                .padding()

            Spacer()
        }
    }
}
