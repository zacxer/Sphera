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

    private let tubeWidth: CGFloat = 70
    private let tubeHeight: CGFloat = 240
    private let ballSize: CGFloat = 52

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottom) {
                // Glow di sfondo per tubi selezionati o completi
                if isSelected || tube.isComplete {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            RadialGradient(
                                colors: [
                                    (tube.isComplete ? Color.ballGreen : Color.ballYellow).opacity(0.6),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 80
                            )
                        )
                        .frame(width: tubeWidth + 40, height: tubeHeight + 40)
                        .blur(radius: 20)
                }

                // Tubo di vetro
                TubeGlassView(
                    width: tubeWidth,
                    height: tubeHeight,
                    isSelected: isSelected,
                    isComplete: tube.isComplete
                )

                // Container palline - allineato in basso
                VStack(spacing: 3) {
                    Spacer()
                    // Invertiamo l'ordine: l'ultima pallina (quella da spostare) appare in ALTO
                    ForEach(Array(tube.balls.enumerated().reversed()), id: \.element.id) { index, ball in
                        BallView(
                            ball: ball,
                            size: ballSize,
                            isTopBall: index == tube.balls.count - 1
                        )
                    }
                }
                .padding(.horizontal, 9)
                .padding(.bottom, 14)
                .frame(width: tubeWidth, height: tubeHeight, alignment: .bottom)
            }
            .offset(y: isSelected ? -20 : 0)
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.65), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

struct TubeGlassView: View {
    let width: CGFloat
    let height: CGFloat
    let isSelected: Bool
    let isComplete: Bool

    var body: some View {
        ZStack {
            // Ombra del tubo
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.black.opacity(0.4))
                .frame(width: width, height: height)
                .offset(x: 4, y: 6)
                .blur(radius: 8)

            // Corpo principale del tubo - effetto vetro
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.25),
                            Color.white.opacity(0.08),
                            Color.white.opacity(0.12),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: width, height: height)

            // Bordo interno luminoso
            RoundedRectangle(cornerRadius: 25)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.8),
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2.5
                )
                .frame(width: width, height: height)

            // Riflesso principale sinistro
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.5),
                            Color.white.opacity(0.2),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 12, height: height * 0.6)
                .offset(x: -width/2 + 18, y: -height * 0.1)

            // Riflesso secondario destro
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.15),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
                .frame(width: 6, height: height * 0.4)
                .offset(x: width/2 - 14, y: -height * 0.2)

            // Highlight in alto
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.4),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 30
                    )
                )
                .frame(width: 40, height: 20)
                .offset(y: -height/2 + 25)

            // Glow per tubo completo
            if isComplete {
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.ballGreen, lineWidth: 3)
                    .frame(width: width, height: height)
                    .shadow(color: .ballGreen.opacity(0.8), radius: 15)
                    .shadow(color: .ballGreen.opacity(0.5), radius: 25)
            }

            // Glow per selezione
            if isSelected {
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.ballYellow, lineWidth: 3)
                    .frame(width: width, height: height)
                    .shadow(color: .ballYellow.opacity(0.9), radius: 12)
                    .shadow(color: .ballYellow.opacity(0.6), radius: 20)
            }
        }
    }
}

struct BallView: View {
    let ball: Ball
    let size: CGFloat
    let isTopBall: Bool

    var body: some View {
        ZStack {
            // Ombra della pallina
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.black.opacity(0.5),
                            Color.black.opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size/2
                    )
                )
                .frame(width: size, height: size * 0.4)
                .offset(y: size * 0.35)
                .blur(radius: 4)

            // Glow colorato di sfondo
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            ball.ballColor.color.opacity(0.8),
                            ball.ballColor.color.opacity(0.3),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.7
                    )
                )
                .frame(width: size * 1.3, height: size * 1.3)
                .blur(radius: 8)

            // Corpo principale della pallina - gradiente 3D
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            ball.ballColor.highlightColor,
                            ball.ballColor.color,
                            ball.ballColor.color.opacity(0.9),
                            ball.ballColor.color.opacity(0.7)
                        ],
                        center: UnitPoint(x: 0.3, y: 0.25),
                        startRadius: 0,
                        endRadius: size * 0.6
                    )
                )
                .frame(width: size, height: size)

            // Overlay gradiente per profondità
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.0),
                            Color.black.opacity(0.3)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size, height: size)

            // Riflesso principale grande
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.95),
                            Color.white.opacity(0.6),
                            Color.white.opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.25
                    )
                )
                .frame(width: size * 0.45, height: size * 0.35)
                .offset(x: -size * 0.15, y: -size * 0.2)

            // Riflesso piccolo brillante
            Circle()
                .fill(Color.white.opacity(0.95))
                .frame(width: size * 0.12, height: size * 0.12)
                .offset(x: -size * 0.2, y: -size * 0.25)

            // Riflesso secondario
            Circle()
                .fill(Color.white.opacity(0.4))
                .frame(width: size * 0.06, height: size * 0.06)
                .offset(x: -size * 0.08, y: -size * 0.32)

            // Riflesso inferiore (ambiente)
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            ball.ballColor.highlightColor.opacity(0.4),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.2
                    )
                )
                .frame(width: size * 0.5, height: size * 0.2)
                .offset(x: size * 0.1, y: size * 0.28)

            // Bordo luminoso sottile
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.6),
                            Color.white.opacity(0.1),
                            ball.ballColor.color.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
                .frame(width: size - 1, height: size - 1)

            // Indicatore pallina in cima (sottile glow)
            if isTopBall {
                Circle()
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    .frame(width: size + 4, height: size + 4)
                    .shadow(color: .white.opacity(0.3), radius: 4)
            }
        }
        .frame(width: size, height: size)
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

        HStack(spacing: 25) {
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

            TubeView(
                tube: Tube(balls: []),
                isSelected: false,
                onTap: {}
            )
        }
    }
}
