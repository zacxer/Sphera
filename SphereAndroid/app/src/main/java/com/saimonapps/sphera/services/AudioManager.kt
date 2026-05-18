package com.saimonapps.sphera.services

import android.content.Context
import android.media.MediaPlayer
import android.media.SoundPool
import android.media.AudioAttributes
import com.saimonapps.sphera.R

class AudioManager private constructor(private val context: Context) {

    companion object {
        @Volatile private var instance: AudioManager? = null
        fun getInstance(ctx: Context): AudioManager =
            instance ?: synchronized(this) {
                instance ?: AudioManager(ctx.applicationContext).also { instance = it }
            }
    }

    private var mediaPlayer: MediaPlayer? = null
    private val soundPool: SoundPool = SoundPool.Builder()
        .setMaxStreams(5)
        .setAudioAttributes(
            AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_GAME)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()
        )
        .build()

    private var soundSelect = 0
    private var soundMove = 0
    private var soundError = 0
    private var soundComplete = 0
    private var soundWin = 0

    private var soundsLoaded = false

    fun loadSounds() {
        if (soundsLoaded) return
        try {
            soundSelect = soundPool.load(context, R.raw.sfx_select, 1)
            soundMove = soundPool.load(context, R.raw.sfx_move, 1)
            soundError = soundPool.load(context, R.raw.sfx_error, 1)
            soundComplete = soundPool.load(context, R.raw.sfx_complete, 1)
            soundWin = soundPool.load(context, R.raw.sfx_win, 1)
            soundsLoaded = true
        } catch (e: Exception) {
            // Sounds not available, game works without them
        }
    }

    fun startMusic() {
        if (mediaPlayer?.isPlaying == true) return
        try {
            mediaPlayer?.release()
            val tracks = listOf(R.raw.bgm_01, R.raw.bgm_02, R.raw.bgm_03)
            val track = tracks.random()
            mediaPlayer = MediaPlayer.create(context, track)?.apply {
                isLooping = true
                setVolume(0.4f, 0.4f)
                start()
            }
        } catch (e: Exception) {
            // Music not available
        }
    }

    fun stopMusic() {
        mediaPlayer?.stop()
        mediaPlayer?.release()
        mediaPlayer = null
    }

    fun pauseMusic() { mediaPlayer?.pause() }
    fun resumeMusic() { if (mediaPlayer?.isPlaying == false) mediaPlayer?.start() }

    fun playSelectSound() = playSound(soundSelect)
    fun playMoveSound() = playSound(soundMove)
    fun playErrorSound() = playSound(soundError)
    fun playTubeCompleteSound() = playSound(soundComplete)
    fun playWinSound() = playSound(soundWin)

    private fun playSound(soundId: Int) {
        if (soundId == 0) return
        try { soundPool.play(soundId, 1f, 1f, 0, 0, 1f) } catch (e: Exception) {}
    }

    fun release() {
        stopMusic()
        soundPool.release()
        instance = null
    }
}
