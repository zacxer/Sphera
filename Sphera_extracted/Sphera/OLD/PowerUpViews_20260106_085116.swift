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
                        count: settings.getPowerUpCount(type),
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
    }
}

// MARK: - Power-up Button

struct PowerUpButton: View {
    let type: PowerUpType
    let count: Int
    let coins: Int
    let isDisabled: Bool
    let action: () -> Void

    @State private var isPressed = false

    // Mostra costo se non ha quantità ma può pagare con monete
    private var badgeText: String? {
        if count > 0 {
            return "\(count)"
        } else if coins >= type.cost {
            return "$"  // Indica che costa monete
        }
        return nil
    }

    private var badgeColor: Color {
        if count > 0 {
            return type.color
        } else {
            return Color(hex: "F59E0B")  // Colore monete
        }
    }

    var body: some View {
        Button(action: {
            if !isDisabled {
                action()
            }
        }) {
            ZStack {
                // Background
                Circle()
                    .fill(
                        isDisabled
                            ? Color.gray.opacity(0.3)
                            : type.color.opacity(0.3)
                    )
                    .frame(width: 28, height: 28)

                // Border
                Circle()
                    .stroke(
                        isDisabled
                            ? Color.gray.opacity(0.5)
                            : type.color,
                        lineWidth: 1
                    )
                    .frame(width: 28, height: 28)

                // Icon
                Image(systemName: type.icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(isDisabled ? .gray : type.color)

                // Counter badge
                if let badge = badgeText {
                    Text(badge)
                        .font(.system(size: 6, weight: .bold))
                        .foregroundColor(.white)
                        .padding(2)
                        .background(Circle().fill(badgeColor))
                        .offset(x: 10, y: -10)
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1)
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

                            // Watch AD for coins button
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
                                PowerUpShopItem(type: type, settings: settings)
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
    @ObservedObject var settings: SettingsManager

    // Computed per forzare refresh
    private var currentCount: Int {
        settings.getPowerUpCount(type)
    }

    private var canBuy: Bool {
        settings.coins >= type.cost
    }

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
                HStack {
                    Text(type.displayName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)

                    Text("x\(currentCount)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(currentCount > 0 ? .green : .white.opacity(0.5))
                }

                Text(type.description)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(2)
            }

            Spacer()

            // Buy button
            Button(action: {
                _ = settings.buyPowerUp(type)
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 14))
                    Text("\(type.cost)")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(canBuy ? .white : .gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(
                            canBuy
                                ? Color(hex: "F59E0B")
                                : Color.gray.opacity(0.3)
                        )
                )
            }
            .disabled(!canBuy)
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
