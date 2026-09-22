//
//  TubeView.swift
//  BallSortPuzzle
//
//  Created on 2026-01-02.
//

import SwiftUI

struct TubeView: View {
    let tube: Tube
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottom) {
                // Tubo di vetro
                TubeGlassView(isSelected: isSelected, isComplete: tube.isComplete)

                // Palline
                VStack(spacing: 4) {
                    ForEach(tube.balls.indices, id: \.self) { index in
                        BallView(ball: tube.balls[index])
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            ))
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 10)
            }
            .offset(y: isSelected ? -15 : 0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

struct TubeGlassView: View {
    let isSelected: Bool
    let isComplete: Bool

    var body: some View {
        ZStack {
            // Corpo del tubo
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 56, height: 180)

            // Bordo luminoso
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(isSelected ? 0.8 : 0.4),
                            Color.white.opacity(isSelected ? 0.4 : 0.1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: isSelected ? 3 : 2
                )
                .frame(width: 56, height: 180)

            // Riflesso vetro
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.3),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
                .frame(width: 20, height: 80)
                .offset(x: -12, y: -30)

            // Glow per tubo completo
            if isComplete {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.ballGreen.opacity(0.2))
                    .frame(width: 56, height: 180)
                    .blur(radius: 8)
            }

            // Glow per selezione
            if isSelected {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.ballYellow, lineWidth: 2)
                    .frame(width: 56, height: 180)
                    .shadow(color: .ballYellow.opacity(0.5), radius: 10)
            }
        }
    }
}

struct BallView: View {
    let ball: Ball

    var body: some View {
        ZStack {
            // Ombra della pallina
            Circle()
                .fill(Color.black.opacity(0.3))
                .frame(width: 38, height: 38)
                .offset(y: 3)
                .blur(radius: 4)

            // Corpo principale della pallina
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            ball.ballColor.highlightColor,
                            ball.ballColor.color,
                            ball.ballColor.color.opacity(0.8)
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 40
                    )
                )
                .frame(width: 40, height: 40)

            // Riflesso principale
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.9),
                            Color.white.opacity(0)
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 20
                    )
                )
                .frame(width: 40, height: 40)
                .offset(x: -5, y: -5)

            // Highlight piccolo
            Circle()
                .fill(Color.white.opacity(0.9))
                .frame(width: 8, height: 8)
                .offset(x: -10, y: -10)

            // Riflesso secondario
            Circle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 4, height: 4)
                .offset(x: -6, y: -14)
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

        HStack(spacing: 20) {
            TubeView(
                tube: Tube(balls: [
                    Ball(color: .red),
                    Ball(color: .blue),
                    Ball(color: .green),
                    Ball(color: .yellow)
                ]),
                isSelected: false,
                onTap: {}
            )

            TubeView(
                tube: Tube(balls: [
                    Ball(color: .purple),
                    Ball(color: .purple)
                ]),
                isSelected: true,
                onTap: {}
            )

            TubeView(
                tube: Tube(balls: [
                    Ball(color: .red),
                    Ball(color: .red),
                    Ball(color: .red),
                    Ball(color: .red)
                ]),
                isSelected: false,
                onTap: {}
            )
        }
    }
}
