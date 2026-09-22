//
//  ShapesTutorialView.swift
//  BallSortPuzzle
//
//  Created on 2026-01-03.
//  FASE 3: Tutorial per le nuove forme
//

import SwiftUI

struct ShapesTutorialView: View {
    @Binding var isPresented: Bool
    let availableShapes: [ShapeType]

    var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isPresented = false
                    }
                }

            // Card principale
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text(L10n.shapesTutorialTitle)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    Text(L10n.shapesTutorialSubtitle)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }

                // Mostra tutte le forme disponibili
                HStack(spacing: 15) {
                    ForEach(availableShapes, id: \.self) { shape in
                        VStack(spacing: 8) {
                            // La forma
                            shapePreview(shape: shape, color: .blue)

                            // Nome
                            Text(shape.displayName)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                .padding(.vertical, 10)

                Divider()
                    .background(Color.white.opacity(0.3))

                // Regole
                VStack(alignment: .leading, spacing: 16) {
                    RuleRowView(
                        icon: "arrow.up.arrow.down",
                        iconColor: .ballYellow,
                        text: L10n.shapesTutorialRule1
                    )

                    RuleRowView(
                        icon: "checkmark.circle.fill",
                        iconColor: .ballGreen,
                        text: L10n.shapesTutorialRule2
                    )
                }
                .padding(.horizontal, 10)

                Divider()
                    .background(Color.white.opacity(0.3))

                // Esempio visivo
                VStack(spacing: 12) {
                    Text(L10n.shapesTutorialExample)
                        .font(.subheadline.bold())
                        .foregroundColor(.white)

                    HStack(spacing: 30) {
                        // Esempio OK - stesso colore
                        VStack(spacing: 4) {
                            HStack(spacing: 2) {
                                shapePreview(shape: .ball, color: .red)
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.white)
                                    .font(.caption)
                                shapePreview(shape: .cube, color: .red)
                            }
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.ballGreen)
                                .font(.caption)
                            Text(L10n.shapesTutorialSameColor)
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }

                        // Esempio OK - stessa forma
                        VStack(spacing: 4) {
                            HStack(spacing: 2) {
                                shapePreview(shape: .star, color: .blue)
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.white)
                                    .font(.caption)
                                shapePreview(shape: .star, color: .yellow)
                            }
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.ballGreen)
                                .font(.caption)
                            Text(L10n.shapesTutorialSameShape)
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }

                        // Esempio NO
                        VStack(spacing: 4) {
                            HStack(spacing: 2) {
                                shapePreview(shape: .ball, color: .purple)
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.white)
                                    .font(.caption)
                                shapePreview(shape: .cube, color: .green)
                            }
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.caption)
                            Text(L10n.shapesTutorialNoMatch)
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }

                // Bottone chiudi
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isPresented = false
                    }
                }) {
                    Text(L10n.shapesTutorialGotIt)
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [Color.ballYellow, Color.orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                }
                .padding(.top, 5)
            }
            .padding(25)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [Color.backgroundDark, Color.backgroundLight.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.5), radius: 30)
            .padding(.horizontal, 25)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }

    @ViewBuilder
    private func shapePreview(shape: ShapeType, color: BallColor) -> some View {
        switch shape {
        case .ball:
            BallShapeView(color: color, size: 32)
        case .cube:
            CubeShapeView(color: color, size: 32)
        case .pyramid:
            PyramidShapeView(color: color, size: 32)
        case .star:
            StarShapeView(color: color, size: 32)
        case .diamond:
            DiamondShapeView(color: color, size: 32)
        }
    }
}

struct RuleRowView: View {
    let icon: String
    let iconColor: Color
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(iconColor)
                .frame(width: 30)

            Text(text)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.backgroundDark.ignoresSafeArea()

        ShapesTutorialView(
            isPresented: .constant(true),
            availableShapes: [.ball, .cube, .pyramid]
        )
    }
}
