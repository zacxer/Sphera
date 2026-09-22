//
//  ContentView.swift
//  BallSortPuzzle
//
//  Created on 2026-01-02.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameViewModel = GameViewModel()
    @StateObject private var audioManager = AudioManager.shared
    @State private var showMenu = true

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // Background animato
                AnimatedBackgroundView()

                if showMenu {
                    MenuView(showMenu: $showMenu, gameViewModel: gameViewModel)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                } else {
                    GameView(gameViewModel: gameViewModel, showMenu: $showMenu)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }
            .animation(nil, value: showMenu)

            // Banner pubblicitario in basso (sempre visibile)
            BannerAdView()
        }
        .ignoresSafeArea(.keyboard)
        .onChange(of: showMenu) { _, newValue in
            // Avvia musica random quando si entra in partita
            if !newValue {
                audioManager.playRandomMusic()
            } else {
                // Ferma musica quando si torna al menu
                audioManager.stopMusic()
            }
        }
    }
}

struct AnimatedBackgroundView: View {
    @State private var animateGradient = false

    var body: some View {
        ZStack {
            // Gradiente base animato
            LinearGradient(
                colors: [
                    Color(hex: "0F0C29"),
                    Color(hex: "302B63"),
                    Color(hex: "24243E")
                ],
                startPoint: animateGradient ? .topLeading : .bottomLeading,
                endPoint: animateGradient ? .bottomTrailing : .topTrailing
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }

            // Cerchi luminosi di sfondo
            GeometryReader { geo in
                ZStack {
                    // Glow viola
                    Circle()
                        .fill(Color.ballPurple.opacity(0.15))
                        .frame(width: 300, height: 300)
                        .blur(radius: 80)
                        .offset(x: -geo.size.width * 0.3, y: -geo.size.height * 0.2)

                    // Glow blu
                    Circle()
                        .fill(Color.ballBlue.opacity(0.12))
                        .frame(width: 250, height: 250)
                        .blur(radius: 70)
                        .offset(x: geo.size.width * 0.3, y: geo.size.height * 0.3)

                    // Glow verde sottile
                    Circle()
                        .fill(Color.ballGreen.opacity(0.08))
                        .frame(width: 200, height: 200)
                        .blur(radius: 60)
                        .offset(x: geo.size.width * 0.1, y: -geo.size.height * 0.35)
                }
            }

            // Particelle/Stelle
            ParticlesView()
        }
    }
}

struct ParticlesView: View {
    let particleCount = 30

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<particleCount, id: \.self) { i in
                ParticleView(
                    size: CGFloat.random(in: 2...5),
                    position: CGPoint(
                        x: CGFloat.random(in: 0...geo.size.width),
                        y: CGFloat.random(in: 0...geo.size.height)
                    ),
                    delay: Double(i) * 0.1
                )
            }
        }
    }
}

struct ParticleView: View {
    let size: CGFloat
    let position: CGPoint
    let delay: Double

    @State private var opacity: Double = 0.3
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: size, height: size)
            .opacity(opacity)
            .scaleEffect(scale)
            .position(position)
            .blur(radius: 0.5)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: Double.random(in: 2...4))
                    .repeatForever(autoreverses: true)
                    .delay(delay.truncatingRemainder(dividingBy: 2))
                ) {
                    opacity = Double.random(in: 0.5...0.9)
                    scale = CGFloat.random(in: 0.8...1.3)
                }
            }
    }
}

#Preview {
    ContentView()
}
