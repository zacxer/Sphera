//
//  SpecialTubeOverlays.swift
//  BallSortPuzzle
//
//  Created on 2026-01-03.
//

import SwiftUI

// MARK: - Frozen Tube Overlay

struct FrozenTubeOverlay: View {
    let freezeCountdown: Int
    let tubeWidth: CGFloat
    let tubeHeight: CGFloat

    @State private var snowflakeRotation: Double = 0
    @State private var frostPulse: Bool = false

    var body: some View {
        ZStack {
            // Effetto brina sui bordi del tubo
            RoundedRectangle(cornerRadius: 25)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(hex: "A8E6FF").opacity(frostPulse ? 0.9 : 0.7),
                            Color(hex: "00D4FF").opacity(0.4),
                            Color(hex: "A8E6FF").opacity(frostPulse ? 0.8 : 0.5)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 4
                )
                .frame(width: tubeWidth, height: tubeHeight)
                .shadow(color: Color(hex: "00D4FF").opacity(0.5), radius: 10)

            // Glow ciano di sfondo
            RoundedRectangle(cornerRadius: 25)
                .fill(Color(hex: "00D4FF").opacity(0.1))
                .frame(width: tubeWidth, height: tubeHeight)

            // Countdown badge in alto
            if freezeCountdown > 0 {
                VStack {
                    HStack(spacing: 4) {
                        Image(systemName: "snowflake")
                            .rotationEffect(.degrees(snowflakeRotation))
                        Text("\(freezeCountdown)")
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color(hex: "00D4FF").opacity(0.9))
                            .shadow(color: Color(hex: "00D4FF").opacity(0.6), radius: 8)
                    )
                    Spacer()
                }
                .frame(height: tubeHeight)
                .offset(y: -20)
            }

            // Cristalli di ghiaccio decorativi
            ForEach(0..<4, id: \.self) { i in
                Image(systemName: "snowflake")
                    .font(.system(size: 8))
                    .foregroundColor(Color(hex: "A8E6FF").opacity(0.6))
                    .offset(
                        x: CGFloat([-20, 20, -15, 18][i]),
                        y: CGFloat([-60, -30, 40, 70][i])
                    )
                    .rotationEffect(.degrees(Double(i) * 45))
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                snowflakeRotation = 360
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                frostPulse = true
            }
        }
    }
}

// MARK: - Tall Tube Badge

struct TallTubeBadge: View {
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "arrow.up")
            Text("x6")
        }
        .font(.system(size: 11, weight: .bold))
        .foregroundColor(Color(hex: "FFD700"))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color(hex: "FFD700").opacity(0.2))
                .overlay(
                    Capsule()
                        .stroke(Color(hex: "FFD700").opacity(0.5), lineWidth: 1)
                )
        )
        .shadow(color: Color(hex: "FFD700").opacity(0.4), radius: 6)
    }
}

// MARK: - Locked Tube Overlay

struct LockedTubeOverlay: View {
    let isLocked: Bool
    let tubeWidth: CGFloat
    let tubeHeight: CGFloat

    @State private var lockPulse: Bool = false
    @State private var unlockAnimation: Bool = false

    var body: some View {
        ZStack {
            if isLocked {
                // Overlay scuro
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.black.opacity(0.6))
                    .frame(width: tubeWidth, height: tubeHeight)

                // Bordo rosso
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color(hex: "FF6B6B").opacity(0.6), lineWidth: 2)
                    .frame(width: tubeWidth, height: tubeHeight)

                // Lucchetto
                Image(systemName: "lock.fill")
                    .font(.system(size: 30))
                    .foregroundColor(Color(hex: "FF6B6B"))
                    .shadow(color: Color(hex: "FF6B6B").opacity(0.8), radius: 10)
                    .scaleEffect(lockPulse ? 1.1 : 1.0)

                // Catene decorative
                VStack {
                    HStack {
                        ChainLink()
                        Spacer()
                        ChainLink()
                    }
                    .padding(.horizontal, 5)
                    Spacer()
                }
                .frame(width: tubeWidth, height: tubeHeight)
            }
        }
        .opacity(unlockAnimation ? 0 : 1)
        .scaleEffect(unlockAnimation ? 1.5 : 1.0)
        .onAppear {
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                lockPulse = true
            }
        }
        .onChange(of: isLocked) { _, newValue in
            if !newValue {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    unlockAnimation = true
                }
            }
        }
    }
}

struct ChainLink: View {
    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { _ in
                Capsule()
                    .fill(Color(hex: "888888").opacity(0.6))
                    .frame(width: 6, height: 10)
            }
        }
    }
}

// MARK: - Portal Tube Overlay

struct PortalTubeOverlay: View {
    let portalColor: PortalColor
    let tubeWidth: CGFloat

    @State private var rotation: Double = 0
    @State private var glowPulse: Bool = false

    var body: some View {
        ZStack {
            // Anello esterno rotante
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [
                            portalColor.color,
                            portalColor.color.opacity(0.3),
                            portalColor.color.opacity(0.1),
                            portalColor.color.opacity(0.3),
                            portalColor.color
                        ],
                        center: .center
                    ),
                    lineWidth: 4
                )
                .frame(width: tubeWidth + 20, height: tubeWidth + 20)
                .rotationEffect(.degrees(rotation))

            // Glow effect pulsante
            Circle()
                .fill(portalColor.color.opacity(glowPulse ? 0.3 : 0.15))
                .frame(width: tubeWidth + 10, height: tubeWidth + 10)
                .blur(radius: 15)

            // Icona portale
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(portalColor.color)
                .shadow(color: portalColor.color.opacity(0.8), radius: 6)

            // Particelle rotanti
            ForEach(0..<6, id: \.self) { i in
                Circle()
                    .fill(portalColor.color)
                    .frame(width: 4, height: 4)
                    .offset(x: (tubeWidth / 2 + 15) * cos(CGFloat(i) * .pi / 3 + CGFloat(rotation) * .pi / 180))
                    .offset(y: (tubeWidth / 2 + 15) * sin(CGFloat(i) * .pi / 3 + CGFloat(rotation) * .pi / 180))
                    .opacity(0.7)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
    }
}

// MARK: - Rotating Tube Overlay

struct RotatingTubeOverlay: View {
    let rotateCountdown: Int
    let tubeWidth: CGFloat
    let tubeHeight: CGFloat

    @State private var arrowRotation: Double = 0
    @State private var isFlashing: Bool = false

    var body: some View {
        ZStack {
            // Bordo arancione
            RoundedRectangle(cornerRadius: 25)
                .stroke(
                    Color(hex: "F97316").opacity(0.5),
                    lineWidth: 2
                )
                .frame(width: tubeWidth, height: tubeHeight)
                .shadow(color: Color(hex: "F97316").opacity(0.3), radius: 8)

            // Frecce rotanti decorative in alto
            VStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 22))
                    .foregroundColor(Color(hex: "F97316"))
                    .rotationEffect(.degrees(arrowRotation))
                    .shadow(color: Color(hex: "F97316").opacity(0.6), radius: 6)
                Spacer()
            }
            .frame(height: tubeHeight)
            .offset(y: -25)

            // Countdown badge in basso
            VStack {
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "arrow.clockwise")
                    Text("\(rotateCountdown)")
                }
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color(hex: "F97316").opacity(isFlashing && rotateCountdown == 1 ? 1.0 : 0.8))
                        .shadow(color: Color(hex: "F97316").opacity(0.5), radius: 6)
                )
            }
            .frame(height: tubeHeight)
            .offset(y: 15)
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                arrowRotation = 360
            }
            if rotateCountdown == 1 {
                withAnimation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
                    isFlashing = true
                }
            }
        }
        .onChange(of: rotateCountdown) { _, newValue in
            if newValue == 1 {
                withAnimation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
                    isFlashing = true
                }
            } else {
                isFlashing = false
            }
        }
    }
}

// MARK: - Frozen Ball Overlay (per la pallina in fondo)

struct FrozenBallOverlay: View {
    let ballSize: CGFloat

    var body: some View {
        ZStack {
            // Copertura di ghiaccio
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "A8E6FF").opacity(0.3),
                            Color(hex: "00D4FF").opacity(0.5),
                            Color(hex: "A8E6FF").opacity(0.2)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: ballSize / 2
                    )
                )
                .frame(width: ballSize, height: ballSize)

            // Cristalli
            Image(systemName: "snowflake")
                .font(.system(size: ballSize * 0.4))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.backgroundDark.ignoresSafeArea()

        HStack(spacing: 30) {
            // Frozen
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 58, height: 215)
                FrozenTubeOverlay(freezeCountdown: 3, tubeWidth: 58, tubeHeight: 215)
            }

            // Locked
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 58, height: 215)
                LockedTubeOverlay(isLocked: true, tubeWidth: 58, tubeHeight: 215)
            }

            // Portal
            VStack {
                PortalTubeOverlay(portalColor: .purple, tubeWidth: 58)
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 58, height: 215)
            }

            // Rotating
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 58, height: 215)
                RotatingTubeOverlay(rotateCountdown: 2, tubeWidth: 58, tubeHeight: 215)
            }
        }
    }
}
