//
//  AudioManager.swift
//  BallSortPuzzle
//
//  Created on 2026-01-03.
//

import AVFoundation
import AudioToolbox
import SwiftUI

@MainActor
class AudioManager: ObservableObject {
    static let shared = AudioManager()

    // MARK: - Power-up Sound IDs (Sistema iOS)
    // Questi sono suoni di sistema già presenti su iOS
    private enum PowerUpSound {
        static let freeze: SystemSoundID = 1104      // Suono freddo/cristallo
        static let shuffle: SystemSoundID = 1109     // Suono swish
        static let undoAll: SystemSoundID = 1107     // Suono rewind
        static let magicWand: SystemSoundID = 1115   // Suono magico
        static let colorBomb: SystemSoundID = 1102   // Suono esplosione
        static let win: SystemSoundID = 1025         // Suono vittoria
        static let error: SystemSoundID = 1053       // Suono errore
        static let coin: SystemSoundID = 1057        // Suono monete
        static let tubeComplete: SystemSoundID = 1114  // Suono completamento tubo (successo)
    }

    // MARK: - Music Player
    private var musicPlayer: AVAudioPlayer?
    private var currentMusicIndex: Int = -1

    // Lista tracce musicali disponibili
    private let musicTracks = [
        "bgm_neon_drive_01",
        "bgm_neon_drive_02",
        "bgm_neon_drive_03"
    ]

    // MARK: - Sound Effects Player
    private var sfxPlayer: AVAudioPlayer?

    // Sound effects disponibili
    private let ballMoveSoundFile = "sfx_button"

    // MARK: - Published state
    @Published var isMusicPlaying: Bool = false

    private init() {
        setupAudioSession()
    }

    // MARK: - Audio Session Setup

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AudioManager: Errore setup audio session - \(error)")
        }
    }

    // MARK: - Music Control

    /// Avvia una traccia musicale random
    func playRandomMusic() {
        guard SettingsManager.shared.musicEnabled else { return }

        // Scegli una traccia diversa dalla precedente
        var newIndex: Int
        repeat {
            newIndex = Int.random(in: 0..<musicTracks.count)
        } while newIndex == currentMusicIndex && musicTracks.count > 1

        currentMusicIndex = newIndex
        playMusic(trackName: musicTracks[newIndex])
    }

    /// Avvia una traccia musicale specifica
    func playMusic(trackName: String) {
        guard SettingsManager.shared.musicEnabled else { return }

        guard let url = Bundle.main.url(forResource: trackName, withExtension: "mp3") else {
            print("AudioManager: Traccia non trovata - \(trackName).mp3")
            return
        }

        do {
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.numberOfLoops = -1 // Loop infinito
            musicPlayer?.volume = 0.4 // Volume moderato per sottofondo
            musicPlayer?.prepareToPlay()
            musicPlayer?.play()
            isMusicPlaying = true
        } catch {
            print("AudioManager: Errore riproduzione musica - \(error)")
        }
    }

    /// Ferma la musica
    func stopMusic() {
        musicPlayer?.stop()
        musicPlayer = nil
        isMusicPlaying = false
    }

    /// Pausa la musica (per ads)
    func pauseMusic() {
        musicPlayer?.pause()
        isMusicPlaying = false
    }

    /// Riprende la musica (dopo ads)
    func resumeMusic() {
        guard SettingsManager.shared.musicEnabled else { return }
        musicPlayer?.play()
        isMusicPlaying = true
    }

    /// Verifica se la musica sta suonando
    var isPlaying: Bool {
        return musicPlayer?.isPlaying ?? false
    }

    /// Pausa/riprende la musica
    func toggleMusic() {
        if isMusicPlaying {
            musicPlayer?.pause()
            isMusicPlaying = false
        } else if musicPlayer != nil {
            musicPlayer?.play()
            isMusicPlaying = true
        } else {
            playRandomMusic()
        }
    }

    /// Aggiorna stato musica quando cambia impostazione
    func updateMusicState() {
        if SettingsManager.shared.musicEnabled {
            if !isMusicPlaying {
                playRandomMusic()
            }
        } else {
            stopMusic()
        }
    }

    // MARK: - Sound Effects

    /// Riproduce il suono di movimento pallina
    func playBallMoveSound() {
        guard SettingsManager.shared.soundEnabled else { return }

        guard let url = Bundle.main.url(forResource: ballMoveSoundFile, withExtension: "wav") else {
            print("AudioManager: Suono non trovato - \(ballMoveSoundFile).wav")
            return
        }

        do {
            sfxPlayer = try AVAudioPlayer(contentsOf: url)
            sfxPlayer?.volume = 0.6
            sfxPlayer?.prepareToPlay()
            sfxPlayer?.play()
        } catch {
            print("AudioManager: Errore riproduzione sfx - \(error)")
        }
    }

    /// Riproduce un suono custom
    func playSoundEffect(name: String, ext: String = "wav", volume: Float = 0.6) {
        guard SettingsManager.shared.soundEnabled else { return }

        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("AudioManager: Suono non trovato - \(name).\(ext)")
            return
        }

        do {
            sfxPlayer = try AVAudioPlayer(contentsOf: url)
            sfxPlayer?.volume = volume
            sfxPlayer?.prepareToPlay()
            sfxPlayer?.play()
        } catch {
            print("AudioManager: Errore riproduzione sfx - \(error)")
        }
    }

    // MARK: - Power-up Sounds (Suoni di Sistema)

    /// Suono Freeze Timer - cristallo/ghiaccio
    func playFreezeSound() {
        guard SettingsManager.shared.soundEnabled else { return }
        AudioServicesPlaySystemSound(PowerUpSound.freeze)
    }

    /// Suono Shuffle - swish/movimento
    func playShuffleSound() {
        guard SettingsManager.shared.soundEnabled else { return }
        AudioServicesPlaySystemSound(PowerUpSound.shuffle)
    }

    /// Suono Undo All - rewind
    func playUndoAllSound() {
        guard SettingsManager.shared.soundEnabled else { return }
        AudioServicesPlaySystemSound(PowerUpSound.undoAll)
    }

    /// Suono Magic Wand - magico/sparkle
    func playMagicWandSound() {
        guard SettingsManager.shared.soundEnabled else { return }
        AudioServicesPlaySystemSound(PowerUpSound.magicWand)
    }

    /// Suono Color Bomb - esplosione
    func playColorBombSound() {
        guard SettingsManager.shared.soundEnabled else { return }
        AudioServicesPlaySystemSound(PowerUpSound.colorBomb)
    }

    /// Suono Vittoria
    func playWinSound() {
        guard SettingsManager.shared.soundEnabled else { return }
        AudioServicesPlaySystemSound(PowerUpSound.win)
    }

    /// Suono Errore
    func playErrorSound() {
        guard SettingsManager.shared.soundEnabled else { return }
        AudioServicesPlaySystemSound(PowerUpSound.error)
    }

    /// Suono Monete
    func playCoinSound() {
        guard SettingsManager.shared.soundEnabled else { return }
        AudioServicesPlaySystemSound(PowerUpSound.coin)
    }

    /// Suono Completamento Tubo
    func playTubeCompleteSound() {
        guard SettingsManager.shared.soundEnabled else { return }
        AudioServicesPlaySystemSound(PowerUpSound.tubeComplete)
    }
}
