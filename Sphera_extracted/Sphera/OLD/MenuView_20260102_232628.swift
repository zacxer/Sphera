//
//  MenuView.swift
//  BallSortPuzzle
//
//  Created on 2026-01-02.
//

import SwiftUI

struct MenuView: View {
    @Binding var showMenu: Bool
    @ObservedObject var gameViewModel: GameViewModel

    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var buttonsOffset: CGFloat = 50
    @State private var buttonsOpacity: Double = 0

    var body: some View {
        VStack(spacing: 50) {
            Spacer()

            // Logo animato
            VStack(spacing: 24) {
                // Tubi decorativi animati
                HStack(spacing: 16) {
                    AnimatedTubePreview(colors: [.ballRed, .ballBlue, .ballGreen, .ballYellow], delay: 0)
                    AnimatedTubePreview(colors: [.ballPurple, .ballYellow, .ballBlue, .ballRed], delay: 0.1)
                    AnimatedTubePreview(colors: [.ballGreen, .ballPurple, .ballRed, .ballBlue], delay: 0.2)
                }

                // Titolo
                VStack(spacing: 8) {
                    Text("BALL SORT")
                        .font(.system(size: 46, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.85)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .ballPurple.opacity(0.6), radius: 15)
                        .shadow(color: .black.opacity(0.3), radius: 3, y: 2)

                    Text("PUZZLE")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.ballPurple, .ballBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .ballBlue.opacity(0.5), radius: 10)
                }
            }
            .scaleEffect(logoScale)
            .opacity(logoOpacity)

            Spacer()

            // Pulsanti
            VStack(spacing: 18) {
                // Pulsante Gioca
                PlayButton {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        showMenu = false
                    }
                }

                // Info livello attuale
                HStack(spacing: 12) {
                    Image(systemName: "flag.fill")
                        .foregroundColor(.ballYellow)

                    Text("Livello \(gameViewModel.currentLevel)")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
            }
            .offset(y: buttonsOffset)
            .opacity(buttonsOpacity)

            Spacer()

            // Footer
            VStack(spacing: 8) {
                Text("Ordina le palline per colore!")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white.opacity(0.6))

                HStack(spacing: 4) {
                    ForEach([Color.ballRed, .ballBlue, .ballGreen, .ballYellow, .ballPurple], id: \.self) { color in
                        Circle()
                            .fill(color)
                            .frame(width: 8, height: 8)
                    }
                }
                .opacity(0.7)
            }
            .padding(.bottom, 40)
        }
        .padding()
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3)) {
                buttonsOffset = 0
                buttonsOpacity = 1.0
            }
        }
    }
}

struct AnimatedTubePreview: View {
    let colors: [Color]
    let delay: Double

    @State private var animate = false

    var body: some View {
        VStack(spacing: 4) {
            ForEach(colors.indices.reversed(), id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                colors[index].opacity(1),
                                colors[index].opacity(0.8)
                            ],
                            center: UnitPoint(x: 0.3, y: 0.3),
                            startRadius: 0,
                            endRadius: 15
                        )
                    )
                    .overlay(
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.white.opacity(0.8), Color.clear],
                                    center: UnitPoint(x: 0.3, y: 0.25),
                                    startRadius: 0,
                                    endRadius: 8
                                )
                            )
                    )
                    .frame(width: 28, height: 28)
                    .shadow(color: colors[index].opacity(0.5), radius: 4)
                    .scaleEffect(animate ? 1.0 : 0.8)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.6)
                            .delay(delay + Double(3 - index) * 0.08),
                        value: animate
                    )
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.4), Color.white.opacity(0.1)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1.5
                        )
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
        .onAppear {
            animate = true
        }
    }
}

struct PlayButton: View {
    let action: () -> Void

    @State private var isPressed = false
    @State private var glowAnimation = false

    var body: some View {
        Button(action: action) {
            ZStack {
                // Glow animato
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.ballGreen.opacity(0.6), .ballBlue.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 65)
                    .blur(radius: 20)
                    .scaleEffect(glowAnimation ? 1.1 : 1.0)
                    .opacity(glowAnimation ? 0.8 : 0.5)

                // Pulsante principale
                HStack(spacing: 14) {
                    Image(systemName: "play.fill")
                        .font(.title2)

                    Text("GIOCA")
                        .font(.title2.weight(.black))
                        .tracking(2)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    ZStack {
                        // Gradiente base
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.ballGreen, .ballBlue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )

                        // Highlight superiore
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.4), Color.clear],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                    }
                )
                .shadow(color: .ballGreen.opacity(0.5), radius: 12, y: 6)
            }
        }
        .frame(maxWidth: 280)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.2), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowAnimation = true
            }
        }
    }
}

#Preview {
    ZStack {
        AnimatedBackgroundView()
        MenuView(showMenu: .constant(true), gameViewModel: GameViewModel())
    }
}
