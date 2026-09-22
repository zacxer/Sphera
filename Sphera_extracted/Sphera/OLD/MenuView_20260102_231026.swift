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

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Logo/Titolo
            VStack(spacing: 16) {
                // Icona decorativa con tubi e palline
                HStack(spacing: 12) {
                    TubePreviewView(colors: [.ballRed, .ballBlue, .ballRed, .ballBlue])
                    TubePreviewView(colors: [.ballGreen, .ballYellow, .ballGreen, .ballYellow])
                    TubePreviewView(colors: [.ballPurple, .ballRed, .ballPurple, .ballRed])
                }
                .scaleEffect(0.8)

                Text("Ball Sort")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .gray.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                Text("Puzzle")
                    .font(.system(size: 36, weight: .semibold, design: .rounded))
                    .foregroundColor(.ballPurple)
            }

            Spacer()

            // Pulsanti Menu
            VStack(spacing: 20) {
                MenuButton(title: "Gioca", icon: "play.fill") {
                    withAnimation {
                        showMenu = false
                    }
                }

                MenuButton(title: "Livello \(gameViewModel.currentLevel)", icon: "number", style: .secondary) {
                    // Mostra selettore livelli (futuro)
                    withAnimation {
                        showMenu = false
                    }
                }
            }

            Spacer()

            // Footer
            Text("Ordina le palline per colore!")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
                .padding(.bottom, 40)
        }
        .padding()
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    var style: ButtonStyle = .primary
    let action: () -> Void

    enum ButtonStyle {
        case primary, secondary
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.title2.bold())
            }
            .foregroundColor(style == .primary ? .white : .white.opacity(0.9))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                Group {
                    if style == .primary {
                        LinearGradient(
                            colors: [Color.ballPurple, Color.ballBlue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        Color.white.opacity(0.15)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct TubePreviewView: View {
    let colors: [Color]

    var body: some View {
        VStack(spacing: 2) {
            ForEach(colors.indices.reversed(), id: \.self) { index in
                Circle()
                    .fill(colors[index])
                    .frame(width: 20, height: 20)
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        )
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

        MenuView(showMenu: .constant(true), gameViewModel: GameViewModel())
    }
}
