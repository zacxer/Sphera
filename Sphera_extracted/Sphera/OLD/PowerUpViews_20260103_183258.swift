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

    var body: some View {
        HStack(spacing: 8) {
            // Monete
            CoinDisplayView(coins: settings.coins)
                .onTapGesture {
                    showShop = true
                }

            Spacer()

            // Power-up buttons
            ForEach(PowerUpType.allCases, id: \.self) { type in
                PowerUpButton(
                    type: type,
                    count: settings.getPowerUpCount(type),
                    isDisabled: !gameViewModel.canUsePowerUp(type)
                ) {
                    gameViewModel.usePowerUp(type)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .sheet(isPresented: $showShop) {
            PowerUpShopView(settings: settings)
        }
    }
}

// MARK: - Coin Display

struct CoinDisplayView: View {
    let coins: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 18))
                .foregroundColor(Color(hex: "F59E0B"))

            Text("\(coins)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
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
    let isDisabled: Bool
    let action: () -> Void

    @State private var isPressed = false

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
                    .frame(width: 44, height: 44)

                // Border
                Circle()
                    .stroke(
                        isDisabled
                            ? Color.gray.opacity(0.5)
                            : type.color,
                        lineWidth: 2
                    )
                    .frame(width: 44, height: 44)

                // Icon
                Image(systemName: type.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isDisabled ? .gray : type.color)

                // Counter badge
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Circle().fill(type.color))
                        .offset(x: 14, y: -14)
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
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            color.color.opacity(0.9),
                            color.color
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 40
                    )
                )
                .frame(width: 60, height: 60)
                .overlay(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.4), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 55, height: 55)
                )
                .shadow(color: color.color.opacity(0.5), radius: 8)
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
                        // Coins header
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
                        .padding(.vertical, 20)

                        // Power-ups list
                        ForEach(PowerUpType.allCases, id: \.self) { type in
                            PowerUpShopItem(type: type, settings: settings)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(L10n.powerUps)
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

struct PowerUpShopItem: View {
    let type: PowerUpType
    @ObservedObject var settings: SettingsManager

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

                    Text("x\(settings.getPowerUpCount(type))")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
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
                .foregroundColor(settings.canBuyPowerUp(type) ? .white : .gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(
                            settings.canBuyPowerUp(type)
                                ? Color(hex: "F59E0B")
                                : Color.gray.opacity(0.3)
                        )
                )
            }
            .disabled(!settings.canBuyPowerUp(type))
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
