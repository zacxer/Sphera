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
    @StateObject private var settings = SettingsManager.shared

    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var buttonsOffset: CGFloat = 50
    @State private var buttonsOpacity: Double = 0
    @State private var showSettings = false
    @State private var showStats = false
    @State private var showDifficultyPicker = false

    var body: some View {
        VStack(spacing: 30) {
            // Header con stats e settings
            HStack {
                // Pulsante Statistiche
                MenuIconButton(icon: "chart.bar.fill", color: .ballBlue) {
                    showStats = true
                }

                Spacer()

                // Toggle Suono
                MenuIconButton(
                    icon: settings.soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill",
                    color: settings.soundEnabled ? .ballGreen : .gray
                ) {
                    settings.soundEnabled.toggle()
                }

                // Pulsante Impostazioni
                MenuIconButton(icon: "gearshape.fill", color: .ballPurple) {
                    showSettings = true
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)

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
            VStack(spacing: 16) {
                // Pulsante Gioca
                PlayButton {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        showMenu = false
                    }
                }

                // Selettore difficoltà
                Button {
                    showDifficultyPicker = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: gameViewModel.difficulty.icon)
                            .foregroundColor(gameViewModel.difficulty.color)

                        Text(gameViewModel.difficulty.rawValue)
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white.opacity(0.9))

                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                Capsule()
                                    .stroke(gameViewModel.difficulty.color.opacity(0.5), lineWidth: 1.5)
                            )
                    )
                }

                // Info livello attuale
                HStack(spacing: 12) {
                    Image(systemName: "flag.fill")
                        .foregroundColor(.ballYellow)

                    Text("Livello \(gameViewModel.currentLevel)")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.top, 8)
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
            .padding(.bottom, 30)
        }
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
        .sheet(isPresented: $showSettings) {
            SettingsView(gameViewModel: gameViewModel)
        }
        .sheet(isPresented: $showStats) {
            StatsView()
        }
        .sheet(isPresented: $showDifficultyPicker) {
            DifficultyPickerView(gameViewModel: gameViewModel)
                .presentationDetents([.medium])
        }
    }
}

// MARK: - Menu Icon Button

struct MenuIconButton: View {
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 46, height: 46)

                Circle()
                    .stroke(color.opacity(0.4), lineWidth: 1.5)
                    .frame(width: 46, height: 46)

                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }
        }
    }
}

// MARK: - Animated Tube Preview

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

// MARK: - Play Button

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
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.ballGreen, .ballBlue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )

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

// MARK: - Settings View

struct SettingsView: View {
    @ObservedObject var gameViewModel: GameViewModel
    @StateObject private var settings = SettingsManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showResetAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundDark.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Audio
                        SettingsSection(title: "Audio") {
                            SettingsToggle(
                                icon: "speaker.wave.2.fill",
                                title: "Suoni",
                                color: .ballGreen,
                                isOn: $settings.soundEnabled
                            )

                            SettingsToggle(
                                icon: "iphone.radiowaves.left.and.right",
                                title: "Vibrazione",
                                color: .ballBlue,
                                isOn: $settings.vibrationEnabled
                            )
                        }

                        // Gioco
                        SettingsSection(title: "Gioco") {
                            // Reset livello corrente
                            SettingsButton(
                                icon: "arrow.counterclockwise",
                                title: "Ricomincia dal Livello 1",
                                subtitle: "Mantiene le statistiche",
                                color: .ballYellow
                            ) {
                                gameViewModel.resetToFirstLevel()
                                dismiss()
                            }

                            // Reset completo
                            SettingsButton(
                                icon: "trash.fill",
                                title: "Resetta Tutto",
                                subtitle: "Cancella tutti i progressi",
                                color: .ballRed
                            ) {
                                showResetAlert = true
                            }
                        }

                        // Info
                        SettingsSection(title: "Info") {
                            HStack {
                                Text("Versione")
                                    .foregroundColor(.white.opacity(0.7))
                                Spacer()
                                Text("1.0.0")
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Impostazioni")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fatto") {
                        dismiss()
                    }
                    .foregroundColor(.ballBlue)
                }
            }
            .alert("Resetta Tutto?", isPresented: $showResetAlert) {
                Button("Annulla", role: .cancel) { }
                Button("Resetta", role: .destructive) {
                    gameViewModel.resetAllProgress()
                    dismiss()
                }
            } message: {
                Text("Tutti i progressi e le statistiche verranno cancellati. Questa azione non può essere annullata.")
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundColor(.white.opacity(0.5))
                .padding(.leading, 4)

            VStack(spacing: 2) {
                content
            }
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
        }
    }
}

struct SettingsToggle: View {
    let icon: String
    let title: String
    let color: Color
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)

            Text(title)
                .foregroundColor(.white)

            Spacer()

            Toggle("", isOn: $isOn)
                .tint(color)
        }
        .padding()
    }
}

struct SettingsButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .foregroundColor(.white)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding()
        }
    }
}

// MARK: - Stats View

struct StatsView: View {
    @StateObject private var settings = SettingsManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundDark.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Statistiche principali
                        HStack(spacing: 16) {
                            StatCard(
                                icon: "star.fill",
                                value: "\(settings.totalStars)",
                                title: "Stelle",
                                color: .ballYellow
                            )

                            StatCard(
                                icon: "trophy.fill",
                                value: "\(settings.highScore)",
                                title: "Record",
                                color: .ballPurple
                            )
                        }

                        HStack(spacing: 16) {
                            StatCard(
                                icon: "checkmark.circle.fill",
                                value: "\(settings.gamesCompleted)",
                                title: "Completati",
                                color: .ballGreen
                            )

                            StatCard(
                                icon: "flame.fill",
                                value: settings.difficulty.rawValue,
                                title: "Difficoltà",
                                color: settings.difficulty.color
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Statistiche")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fatto") {
                        dismiss()
                    }
                    .foregroundColor(.ballBlue)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let title: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
                .shadow(color: color.opacity(0.5), radius: 8)

            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Difficulty Picker

struct DifficultyPickerView: View {
    @ObservedObject var gameViewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundDark.ignoresSafeArea()

                VStack(spacing: 16) {
                    ForEach(Difficulty.allCases, id: \.self) { difficulty in
                        DifficultyCard(
                            difficulty: difficulty,
                            isSelected: gameViewModel.difficulty == difficulty
                        ) {
                            gameViewModel.changeDifficulty(to: difficulty)
                            dismiss()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Difficoltà")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Annulla") {
                        dismiss()
                    }
                    .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct DifficultyCard: View {
    let difficulty: Difficulty
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icona
                ZStack {
                    Circle()
                        .fill(difficulty.color.opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: difficulty.icon)
                        .font(.title2)
                        .foregroundColor(difficulty.color)
                }

                // Testo
                VStack(alignment: .leading, spacing: 4) {
                    Text(difficulty.rawValue)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(difficulty.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }

                Spacer()

                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(difficulty.color)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(isSelected ? 0.1 : 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? difficulty.color : Color.clear, lineWidth: 2)
                    )
            )
        }
    }
}

#Preview {
    ZStack {
        AnimatedBackgroundView()
        MenuView(showMenu: .constant(true), gameViewModel: GameViewModel())
    }
}
