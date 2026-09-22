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
    var isHintSource: Bool = false
    var isHintDest: Bool = false
    var isAnimatingSource: Bool = false  // Nasconde la pallina in cima durante animazione
    let onTap: () -> Void

    private let tubeWidth: CGFloat = 58
    private let ballSize: CGFloat = 44

    // Altezza del tubo (visiva)
    private var tubeHeight: CGFloat {
        tube.type == .tall ? 310 : 215  // Tall = 1.5x height
    }

    @State private var hintPulse: Bool = false

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottom) {
                // Glow di sfondo per tubi selezionati, completi o hint
                // SEMPRE presente ma con opacità per evitare cambi layout
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        RadialGradient(
                            colors: [
                                hintGlowColor.opacity(0.6),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: tubeWidth + 40, height: tubeHeight + 40)
                    .blur(radius: 20)
                    .opacity(isSelected || tube.isComplete || isHintSource || isHintDest ? 1 : 0)

                // Tubo di vetro
                TubeGlassView(
                    width: tubeWidth,
                    height: tubeHeight,
                    isSelected: isSelected,
                    isComplete: tube.isComplete,
                    isHintSource: isHintSource,
                    isHintDest: isHintDest,
                    hintPulse: hintPulse
                )

                // Container palline - allineato in basso
                VStack(spacing: 3) {
                    Spacer()
                    // Invertiamo l'ordine: l'ultima pallina (quella da spostare) appare in ALTO
                    ForEach(Array(tube.balls.enumerated().reversed()), id: \.element.id) { index, ball in
                        let isTopBall = index == tube.balls.count - 1
                        // Nascondi la pallina in cima se sta animando
                        if !(isTopBall && isAnimatingSource) {
                            ZStack {
                                BallView(
                                    ball: ball,
                                    size: ballSize,
                                    isTopBall: isTopBall,
                                    isHintBall: isHintSource && isTopBall
                                )

                                // Overlay ghiaccio sulla pallina in CIMA se frozen
                                if isTopBall && tube.isTopBallFrozen {
                                    FrozenBallOverlay(ballSize: ballSize)
                                }
                            }
                        } else {
                            // Spazio vuoto per mantenere layout
                            Color.clear
                                .frame(width: ballSize, height: ballSize)
                        }
                    }
                }
                .padding(.horizontal, 9)
                .padding(.bottom, 14)
                .frame(width: tubeWidth, height: tubeHeight, alignment: .bottom)
                .animation(nil, value: tube.balls.count)
                .transaction { $0.animation = nil }

                // MARK: - Overlay tubi speciali

                // Frozen tube overlay
                if tube.type == .frozen {
                    FrozenTubeOverlay(
                        freezeCountdown: tube.freezeCountdown ?? 0,
                        tubeWidth: tubeWidth,
                        tubeHeight: tubeHeight
                    )
                }

                // Locked tube overlay
                if tube.type == .locked {
                    LockedTubeOverlay(
                        isLocked: tube.isTubeLocked,
                        tubeWidth: tubeWidth,
                        tubeHeight: tubeHeight
                    )
                }

                // Rotating tube overlay
                if tube.type == .rotating {
                    RotatingTubeOverlay(
                        rotateCountdown: tube.rotateCountdown ?? 0,
                        tubeWidth: tubeWidth,
                        tubeHeight: tubeHeight
                    )
                }

                // Portal tube overlay (posizionato sopra il tubo)
                if tube.isPortal {
                    PortalTubeOverlay(
                        portalColor: tube.portalColor ?? .purple,
                        tubeWidth: tubeWidth
                    )
                    .offset(y: -tubeHeight/2 - 25)
                }

                // Tall tube badge
                if tube.type == .tall {
                    VStack {
                        TallTubeBadge()
                        Spacer()
                    }
                    .frame(height: tubeHeight)
                    .offset(y: -20)
                }

                // Freccia indicatore per hint destinazione
                if isHintDest {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.ballGreen, .green],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .ballGreen.opacity(0.8), radius: 8)
                        .offset(y: -tubeHeight/2 - 25)
                        .scaleEffect(hintPulse ? 1.2 : 0.9)
                }
            }
            // Selezione indicata solo dal glow (nessuno scale/movimento)
        }
        .buttonStyle(.plain)
        // Frame dinamico per ogni tubo
        .frame(width: tubeWidth + 30, height: tubeHeight + 40)
        // BLOCCA tutte le animazioni implicite sui tubi
        .transaction { $0.animation = nil }
        .onChange(of: isHintSource) { _, newValue in
            if newValue {
                startHintAnimation()
            } else {
                hintPulse = false
            }
        }
        .onChange(of: isHintDest) { _, newValue in
            if newValue {
                startHintAnimation()
            } else {
                hintPulse = false
            }
        }
        .onAppear {
            if isHintSource || isHintDest {
                startHintAnimation()
            }
        }
    }

    private var hintGlowColor: Color {
        if isHintSource {
            return .ballYellow
        } else if isHintDest {
            return .ballGreen
        } else if tube.isComplete {
            return .ballGreen
        } else {
            return .ballYellow
        }
    }

    private func startHintAnimation() {
        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
            hintPulse = true
        }
    }
}

struct TubeGlassView: View {
    let width: CGFloat
    let height: CGFloat
    let isSelected: Bool
    let isComplete: Bool
    var isHintSource: Bool = false
    var isHintDest: Bool = false
    var hintPulse: Bool = false

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

            // Glow per hint sorgente (giallo pulsante)
            if isHintSource {
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.ballYellow, lineWidth: hintPulse ? 4 : 2)
                    .frame(width: width, height: height)
                    .shadow(color: .ballYellow.opacity(hintPulse ? 1.0 : 0.6), radius: hintPulse ? 20 : 10)
                    .shadow(color: .ballYellow.opacity(hintPulse ? 0.8 : 0.4), radius: hintPulse ? 30 : 15)
            }

            // Glow per hint destinazione (verde pulsante)
            if isHintDest {
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.ballGreen, lineWidth: hintPulse ? 4 : 2)
                    .frame(width: width, height: height)
                    .shadow(color: .ballGreen.opacity(hintPulse ? 1.0 : 0.6), radius: hintPulse ? 20 : 10)
                    .shadow(color: .ballGreen.opacity(hintPulse ? 0.8 : 0.4), radius: hintPulse ? 30 : 15)
            }
        }
    }
}

struct BallView: View {
    let ball: Ball
    let size: CGFloat
    let isTopBall: Bool
    var isHintBall: Bool = false

    @State private var hintBounce: Bool = false

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

            // Indicatore hint (freccia su)
            if isHintBall {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.ballYellow, .orange],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .ballYellow.opacity(0.8), radius: 6)
                    .offset(y: -size * 0.6)
                    .scaleEffect(hintBounce ? 1.2 : 0.9)
            }
        }
        .frame(width: size, height: size)
        .offset(y: isHintBall && hintBounce ? -8 : 0)
        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: hintBounce)
        .onAppear {
            if isHintBall {
                hintBounce = true
            }
        }
        .onChange(of: isHintBall) { _, newValue in
            hintBounce = newValue
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

        HStack(spacing: 25) {
            TubeView(
                tube: Tube(balls: [
                    Ball(color: .red),
                    Ball(color: .blue),
                    Ball(color: .green),
                    Ball(color: .yellow)
                ]),
                isSelected: false,
                isHintSource: true,
                onTap: {}
            )

            TubeView(
                tube: Tube(balls: [
                    Ball(color: .purple),
                    Ball(color: .purple)
                ]),
                isSelected: false,
                isHintDest: true,
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
