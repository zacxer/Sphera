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
        GeometryReader { geometry in
            VStack(spacing: 20) {
                // Header con stats e settings
                HStack {
                    // Pulsante Statistiche
                    MenuIconButton(icon: "chart.bar.fill", color: .ballBlue) {
                        showStats = true
                    }

                    Spacer()

                    // Pulsante Impostazioni
                    MenuIconButton(icon: "gearshape.fill", color: .ballPurple) {
                        showSettings = true
                    }
                }
                .padding(.horizontal)
                // Rispetta la safe area in alto (orologio/notch)
                .padding(.top, geometry.safeAreaInsets.top > 20 ? 0 : 8)

            Spacer()

            // Logo animato
            VStack(spacing: 16) {
                // Tubi decorativi animati
                HStack(spacing: 12) {
                    AnimatedTubePreview(colors: [.ballRed, .ballBlue, .ballGreen, .ballYellow], delay: 0)
                    AnimatedTubePreview(colors: [.ballPurple, .ballYellow, .ballBlue, .ballRed], delay: 0.1)
                    AnimatedTubePreview(colors: [.ballGreen, .ballPurple, .ballRed, .ballBlue], delay: 0.2)
                }

                // Titolo SPHERA
                VStack(spacing: 6) {
                    ZStack {
                        // Glow viola dietro
                        Text("SPHERA")
                            .font(.system(size: 52, weight: .black, design: .rounded))
                            .foregroundColor(Color(hex: "A855F7"))
                            .blur(radius: 25)
                            .opacity(0.8)

                        // Glow blu
                        Text("SPHERA")
                            .font(.system(size: 52, weight: .black, design: .rounded))
                            .foregroundColor(Color(hex: "3B82F6"))
                            .blur(radius: 15)
                            .opacity(0.5)
                            .offset(y: 3)

                        // Testo principale
                        Text("SPHERA")
                            .font(.system(size: 52, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, Color(hex: "E0E7FF")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: Color(hex: "A855F7").opacity(0.9), radius: 20, x: 0, y: 0)
                            .shadow(color: Color(hex: "7C3AED").opacity(0.6), radius: 40, x: 0, y: 8)
                            .shadow(color: .black.opacity(0.4), radius: 3, y: 2)
                            .tracking(6)
                    }

                    // Sottotitolo
                    Text("BALL SORTING PUZZLE")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                        .tracking(4)
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

                        Text(gameViewModel.difficulty.localizedName)
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

                    Text("\(L10n.level) \(gameViewModel.currentLevel)")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.top, 8)
            }
            .offset(y: buttonsOffset)
            .opacity(buttonsOpacity)

            Spacer()

            // Footer con bottoni lingua e mute
            HStack {
                // Bottone Lingua (sinistra)
                Button {
                    settings.toggleLanguage()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 44, height: 44)

                        Circle()
                            .stroke(Color.ballBlue.opacity(0.4), lineWidth: 1.5)
                            .frame(width: 44, height: 44)

                        Text(settings.language.rawValue)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                Spacer()

                // Testo centrale
                VStack(spacing: 6) {
                    Text(L10n.sortBallsByColor)
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

                Spacer()

                // Bottone Mute (destra)
                Button {
                    settings.toggleMute()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 44, height: 44)

                        Circle()
                            .stroke(settings.isMuted ? Color.gray.opacity(0.4) : Color.ballGreen.opacity(0.4), lineWidth: 1.5)
                            .frame(width: 44, height: 44)

                        Image(systemName: settings.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                            .font(.system(size: 18))
                            .foregroundColor(settings.isMuted ? .gray : .ballGreen)
                    }
                }
            }
            .padding(.horizontal, 20)
            // Padding extra per banner pubblicitario
            .padding(.bottom, 60)
            }
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

// MARK: - Animated Tube Preview (con effetto vetro e palline 3D)

struct AnimatedTubePreview: View {
    let colors: [Color]
    let delay: Double

    @State private var animate = false

    private let tubeWidth: CGFloat = 44
    private let tubeHeight: CGFloat = 140
    private let ballSize: CGFloat = 30

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tubo di vetro
            ZStack {
                // Ombra del tubo
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.black.opacity(0.4))
                    .frame(width: tubeWidth, height: tubeHeight)
                    .offset(x: 3, y: 4)
                    .blur(radius: 6)

                // Corpo principale del tubo - effetto vetro
                RoundedRectangle(cornerRadius: 18)
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
                    .frame(width: tubeWidth, height: tubeHeight)

                // Bordo interno luminoso
                RoundedRectangle(cornerRadius: 18)
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
                        lineWidth: 2
                    )
                    .frame(width: tubeWidth, height: tubeHeight)

                // Riflesso principale sinistro
                RoundedRectangle(cornerRadius: 14)
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
                    .frame(width: 8, height: tubeHeight * 0.6)
                    .offset(x: -tubeWidth/2 + 12, y: -tubeHeight * 0.1)

                // Riflesso secondario destro
                RoundedRectangle(cornerRadius: 10)
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
                    .frame(width: 4, height: tubeHeight * 0.4)
                    .offset(x: tubeWidth/2 - 10, y: -tubeHeight * 0.2)

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
                            endRadius: 20
                        )
                    )
                    .frame(width: 30, height: 15)
                    .offset(y: -tubeHeight/2 + 18)
            }

            // Palline 3D dentro il tubo
            VStack(spacing: 2) {
                ForEach(colors.indices.reversed(), id: \.self) { index in
                    MenuBallView(
                        color: colors[index],
                        size: ballSize,
                        animate: animate,
                        delay: delay + Double(3 - index) * 0.08
                    )
                }
            }
            .padding(.bottom, 10)
        }
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Menu Ball View (pallina 3D GLASS per menu)

struct MenuBallView: View {
    let color: Color
    let size: CGFloat
    let animate: Bool
    let delay: Double

    var body: some View {
        ZStack {
            // Glow colorato di sfondo
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            color.opacity(0.7),
                            color.opacity(0.3),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.7
                    )
                )
                .frame(width: size * 1.4, height: size * 1.4)
                .blur(radius: 6)

            // Ombra sotto la pallina
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.black.opacity(0.4),
                            Color.black.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size/2
                    )
                )
                .frame(width: size, height: size * 0.3)
                .offset(y: size * 0.4)
                .blur(radius: 3)

            // Corpo principale - effetto GLASS
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            color.opacity(0.9),
                            color.opacity(0.75),
                            color.opacity(0.6)
                        ],
                        center: UnitPoint(x: 0.35, y: 0.3),
                        startRadius: 0,
                        endRadius: size * 0.55
                    )
                )
                .frame(width: size, height: size)

            // Overlay vetro - gradiente trasparente
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.35),
                            Color.white.opacity(0.1),
                            Color.clear,
                            Color.black.opacity(0.2)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size, height: size)

            // Riflesso principale GRANDE (effetto glass)
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.95),
                            Color.white.opacity(0.6),
                            Color.white.opacity(0.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size * 0.55, height: size * 0.35)
                .offset(x: -size * 0.08, y: -size * 0.2)

            // Riflesso secondario piccolo brillante
            Circle()
                .fill(Color.white)
                .frame(width: size * 0.12, height: size * 0.12)
                .offset(x: -size * 0.2, y: -size * 0.25)

            // Riflesso terzo ancora piu' piccolo
            Circle()
                .fill(Color.white.opacity(0.7))
                .frame(width: size * 0.06, height: size * 0.06)
                .offset(x: -size * 0.08, y: -size * 0.32)

            // Riflesso inferiore (ambiente)
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.3),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.2
                    )
                )
                .frame(width: size * 0.5, height: size * 0.15)
                .offset(x: size * 0.1, y: size * 0.3)

            // Bordo luminoso glass
            Circle()
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
                    lineWidth: 1.5
                )
                .frame(width: size - 1, height: size - 1)
        }
        .frame(width: size, height: size)
        .scaleEffect(animate ? 1.0 : 0.7)
        .opacity(animate ? 1.0 : 0)
        .animation(
            .spring(response: 0.4, dampingFraction: 0.6).delay(delay),
            value: animate
        )
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

                    Text(L10n.play)
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
                        SettingsSection(title: L10n.audio) {
                            SettingsToggle(
                                icon: "speaker.wave.2.fill",
                                title: L10n.sounds,
                                color: .ballGreen,
                                isOn: $settings.soundEnabled
                            )

                            SettingsToggle(
                                icon: "music.note",
                                title: L10n.music,
                                color: .ballPurple,
                                isOn: Binding(
                                    get: { settings.musicEnabled },
                                    set: { newValue in
                                        settings.musicEnabled = newValue
                                        AudioManager.shared.updateMusicState()
                                    }
                                )
                            )

                            SettingsToggle(
                                icon: "iphone.radiowaves.left.and.right",
                                title: L10n.vibration,
                                color: .ballBlue,
                                isOn: $settings.vibrationEnabled
                            )
                        }

                        // Gioco
                        SettingsSection(title: L10n.game) {
                            // Reset livello corrente
                            SettingsButton(
                                icon: "arrow.counterclockwise",
                                title: L10n.restartFromLevel1,
                                subtitle: L10n.keepsStats,
                                color: .ballYellow
                            ) {
                                gameViewModel.resetToFirstLevel()
                                dismiss()
                            }

                            // Reset completo
                            SettingsButton(
                                icon: "trash.fill",
                                title: L10n.resetAll,
                                subtitle: L10n.deleteAllProgress,
                                color: .ballRed
                            ) {
                                showResetAlert = true
                            }
                        }

                        // Info
                        SettingsSection(title: L10n.info) {
                            HStack {
                                Text(L10n.version)
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
            .navigationTitle(L10n.settings)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L10n.done) {
                        dismiss()
                    }
                    .foregroundColor(.ballBlue)
                }
            }
            .alert(L10n.resetAllQuestion, isPresented: $showResetAlert) {
                Button(L10n.cancel, role: .cancel) { }
                Button(L10n.reset, role: .destructive) {
                    gameViewModel.resetAllProgress()
                    dismiss()
                }
            } message: {
                Text(L10n.resetWarning)
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
                                title: L10n.stars,
                                color: .ballYellow
                            )

                            StatCard(
                                icon: "trophy.fill",
                                value: "\(settings.highScore)",
                                title: L10n.record,
                                color: .ballPurple
                            )
                        }

                        HStack(spacing: 16) {
                            StatCard(
                                icon: "checkmark.circle.fill",
                                value: "\(settings.gamesCompleted)",
                                title: L10n.completed,
                                color: .ballGreen
                            )

                            StatCard(
                                icon: "flame.fill",
                                value: settings.difficulty.localizedName,
                                title: L10n.difficulty,
                                color: settings.difficulty.color
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(L10n.statistics)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L10n.done) {
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
            .navigationTitle(L10n.difficulty)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L10n.cancel) {
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
                    Text(difficulty.localizedName)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(difficulty.localizedDescription)
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
