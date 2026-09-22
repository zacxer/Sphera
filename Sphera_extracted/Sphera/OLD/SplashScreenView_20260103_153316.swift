//
//  SplashScreenView.swift
//  BallSortPuzzle
//
//  Created on 2026-01-03.
//

import SwiftUI

struct SplashScreenView: View {
    // MARK: - Animation States
    @State private var logoOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.8
    @State private var taglineOpacity: Double = 0
    @State private var dotsOpacity: Double = 0
    @State private var currentDot: Int = 0
    @State private var shimmerOffset: CGFloat = -200
    @State private var particlesVisible: Bool = false

    // Timer per i dots animati
    let dotsTimer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // LAYER 1: Immagine di sfondo
            Image("SplashBackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()

            // LAYER 2: Overlay scuro per far risaltare il testo
            LinearGradient(
                colors: [
                    Color.black.opacity(0.6),
                    Color.black.opacity(0.2),
                    Color.clear,
                    Color.black.opacity(0.3)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // LAYER 3: Particelle fluttuanti
            if particlesVisible {
                SplashParticlesView()
                    .ignoresSafeArea()
            }

            // LAYER 4: Contenuto principale
            VStack(spacing: 20) {
                Spacer()
                    .frame(height: 100)

                // LOGO "SPHERA"
                ZStack {
                    // Glow effect dietro il testo
                    Text("SPHERA")
                        .font(.system(size: 56, weight: .black, design: .rounded))
                        .foregroundColor(Color(hex: "A855F7"))
                        .blur(radius: 20)
                        .opacity(logoOpacity * 0.8)

                    // Testo principale
                    Text("SPHERA")
                        .font(.system(size: 56, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color(hex: "E0E0E0")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: Color(hex: "A855F7").opacity(0.8), radius: 15, x: 0, y: 0)
                        .shadow(color: Color(hex: "7C3AED").opacity(0.5), radius: 30, x: 0, y: 5)
                        .tracking(8)
                        .overlay(
                            // Shimmer effect
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            .clear,
                                            .white.opacity(0.4),
                                            .clear
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 80)
                                .offset(x: shimmerOffset)
                                .mask(
                                    Text("SPHERA")
                                        .font(.system(size: 56, weight: .black, design: .rounded))
                                        .tracking(8)
                                )
                        )
                }
                .opacity(logoOpacity)
                .scaleEffect(logoScale)

                // TAGLINE
                Text("The Ultimate Ball Sorting Puzzle")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .tracking(2)
                    .opacity(taglineOpacity)

                Spacer()

                // LOADING DOTS
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.white)
                            .frame(width: 10, height: 10)
                            .scaleEffect(currentDot == index ? 1.3 : 1.0)
                            .opacity(currentDot == index ? 1.0 : 0.4)
                            .animation(.easeInOut(duration: 0.3), value: currentDot)
                    }
                }
                .opacity(dotsOpacity)
                .padding(.bottom, 80)
            }
        }
        .onAppear {
            startAnimations()
        }
        .onReceive(dotsTimer) { _ in
            currentDot = (currentDot + 1) % 3
        }
    }

    // MARK: - Animations
    private func startAnimations() {
        // Particelle appaiono subito
        withAnimation(.easeIn(duration: 0.5)) {
            particlesVisible = true
        }

        // Logo fade in + scale
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3)) {
            logoOpacity = 1
            logoScale = 1
        }

        // Tagline fade in
        withAnimation(.easeOut(duration: 0.6).delay(0.8)) {
            taglineOpacity = 1
        }

        // Loading dots
        withAnimation(.easeOut(duration: 0.4).delay(1.2)) {
            dotsOpacity = 1
        }

        // Shimmer effect continuo
        withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false).delay(1.0)) {
            shimmerOffset = 200
        }
    }
}

// MARK: - Splash Particles View (renamed to avoid conflict with ContentView)

struct SplashParticlesView: View {
    let particleCount = 30

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<particleCount, id: \.self) { index in
                    SplashParticleView(
                        screenSize: geometry.size,
                        delay: Double(index) * 0.1
                    )
                }
            }
        }
    }
}

struct SplashParticleView: View {
    let screenSize: CGSize
    let delay: Double

    @State private var opacity: Double = 0
    @State private var position: CGPoint = .zero
    @State private var scale: CGFloat = 1

    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: CGFloat.random(in: 2...6), height: CGFloat.random(in: 2...6))
            .opacity(opacity)
            .scaleEffect(scale)
            .position(position)
            .onAppear {
                position = CGPoint(
                    x: CGFloat.random(in: 0...screenSize.width),
                    y: CGFloat.random(in: 0...screenSize.height)
                )

                // Fade in
                withAnimation(.easeIn(duration: Double.random(in: 1...2)).delay(delay)) {
                    opacity = Double.random(in: 0.3...0.8)
                }

                // Float animation
                withAnimation(
                    .easeInOut(duration: Double.random(in: 3...6))
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    position.y -= CGFloat.random(in: 20...50)
                    scale = CGFloat.random(in: 0.8...1.2)
                }
            }
    }
}

// MARK: - Preview

#Preview {
    SplashScreenView()
}
