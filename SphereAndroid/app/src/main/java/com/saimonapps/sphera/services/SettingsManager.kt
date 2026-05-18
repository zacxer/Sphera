package com.saimonapps.sphera.services

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.*
import androidx.datastore.preferences.preferencesDataStore
import com.saimonapps.sphera.models.Difficulty
import com.saimonapps.sphera.models.PowerUpType
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

private val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "sphere_settings")

class SettingsManager(private val context: Context) {

    companion object {
        val KEY_SOUND = booleanPreferencesKey("soundEnabled")
        val KEY_MUSIC = booleanPreferencesKey("musicEnabled")
        val KEY_VIBRATION = booleanPreferencesKey("vibrationEnabled")
        val KEY_DIFFICULTY = stringPreferencesKey("difficulty")
        val KEY_LANGUAGE = stringPreferencesKey("language")
        val KEY_HIGH_SCORE = intPreferencesKey("highScore")
        val KEY_TOTAL_STARS = intPreferencesKey("totalStars")
        val KEY_GAMES_COMPLETED = intPreferencesKey("gamesCompleted")
        val KEY_COINS = intPreferencesKey("coins")
        val KEY_PU_SHUFFLE = intPreferencesKey("powerUp_shuffle")
        val KEY_PU_COLOR_BOMB = intPreferencesKey("powerUp_colorBomb")
        val KEY_PU_UNDO_ALL = intPreferencesKey("powerUp_undoAll")
        val KEY_PU_FREEZE = intPreferencesKey("powerUp_freezeTimer")
        val KEY_PU_WAND = intPreferencesKey("powerUp_magicWand")

        @Volatile private var instance: SettingsManager? = null
        fun getInstance(context: Context): SettingsManager =
            instance ?: synchronized(this) {
                instance ?: SettingsManager(context.applicationContext).also { instance = it }
            }
    }

    val soundEnabled: Flow<Boolean> = context.dataStore.data.map { it[KEY_SOUND] ?: true }
    val musicEnabled: Flow<Boolean> = context.dataStore.data.map { it[KEY_MUSIC] ?: true }
    val vibrationEnabled: Flow<Boolean> = context.dataStore.data.map { it[KEY_VIBRATION] ?: true }
    val difficultyFlow: Flow<Difficulty> = context.dataStore.data.map {
        Difficulty.fromKey(it[KEY_DIFFICULTY] ?: Difficulty.MEDIUM.key)
    }
    val languageFlow: Flow<String> = context.dataStore.data.map { it[KEY_LANGUAGE] ?: "IT" }
    val highScoreFlow: Flow<Int> = context.dataStore.data.map { it[KEY_HIGH_SCORE] ?: 0 }
    val totalStarsFlow: Flow<Int> = context.dataStore.data.map { it[KEY_TOTAL_STARS] ?: 0 }
    val gamesCompletedFlow: Flow<Int> = context.dataStore.data.map { it[KEY_GAMES_COMPLETED] ?: 0 }
    val coinsFlow: Flow<Int> = context.dataStore.data.map { it[KEY_COINS] ?: 10 }
    val puShuffleFlow: Flow<Int> = context.dataStore.data.map { it[KEY_PU_SHUFFLE] ?: 1 }
    val puColorBombFlow: Flow<Int> = context.dataStore.data.map { it[KEY_PU_COLOR_BOMB] ?: 0 }
    val puUndoAllFlow: Flow<Int> = context.dataStore.data.map { it[KEY_PU_UNDO_ALL] ?: 2 }
    val puFreezeFlow: Flow<Int> = context.dataStore.data.map { it[KEY_PU_FREEZE] ?: 0 }
    val puWandFlow: Flow<Int> = context.dataStore.data.map { it[KEY_PU_WAND] ?: 0 }

    private val sharedPrefs = context.getSharedPreferences("sphere_progress", Context.MODE_PRIVATE)

    fun getLevelForDifficulty(difficulty: Difficulty): Int =
        sharedPrefs.getInt("level_${difficulty.key}", 1)

    fun saveLevelForDifficulty(difficulty: Difficulty, level: Int) =
        sharedPrefs.edit().putInt("level_${difficulty.key}", level).apply()

    suspend fun setSoundEnabled(v: Boolean) = context.dataStore.edit { it[KEY_SOUND] = v }
    suspend fun setMusicEnabled(v: Boolean) = context.dataStore.edit { it[KEY_MUSIC] = v }
    suspend fun setVibrationEnabled(v: Boolean) = context.dataStore.edit { it[KEY_VIBRATION] = v }
    suspend fun setDifficulty(d: Difficulty) = context.dataStore.edit { it[KEY_DIFFICULTY] = d.key }
    suspend fun setLanguage(lang: String) = context.dataStore.edit { it[KEY_LANGUAGE] = lang }
    suspend fun setHighScore(v: Int) = context.dataStore.edit { it[KEY_HIGH_SCORE] = v }
    suspend fun setCoins(v: Int) = context.dataStore.edit { it[KEY_COINS] = v }

    suspend fun addCoins(amount: Int, currentCoins: Int) =
        context.dataStore.edit { it[KEY_COINS] = currentCoins + amount }

    suspend fun addScore(moves: Int, level: Int, difficulty: Difficulty, currentHigh: Int): Int {
        val base = level * 100
        val moveBonus = maxOf(0, (level * 10 - moves) * 5)
        val multiplier = when (difficulty) {
            Difficulty.EASY -> 1.0; Difficulty.MEDIUM -> 1.5; Difficulty.HARD -> 2.0
        }
        val score = ((base + moveBonus) * multiplier).toInt()
        if (score > currentHigh) context.dataStore.edit { it[KEY_HIGH_SCORE] = score }
        return score
    }

    fun calculateStars(moves: Int, optimalMoves: Int): Int {
        val ratio = moves.toDouble() / optimalMoves
        return when {
            ratio <= 1.2 -> 3; ratio <= 1.8 -> 2; else -> 1
        }
    }

    fun calculateCoinsEarned(level: Int, stars: Int, timeBonus: Boolean, difficulty: Difficulty): Int {
        var earned = 2 + stars
        when (difficulty) {
            Difficulty.MEDIUM -> earned += 1; Difficulty.HARD -> earned += 2; else -> {}
        }
        if (timeBonus) earned += 2
        return earned
    }

    suspend fun setPowerUpCount(type: PowerUpType, count: Int) = context.dataStore.edit {
        val key = when (type) {
            PowerUpType.SHUFFLE -> KEY_PU_SHUFFLE
            PowerUpType.COLOR_BOMB -> KEY_PU_COLOR_BOMB
            PowerUpType.UNDO_ALL -> KEY_PU_UNDO_ALL
            PowerUpType.FREEZE_TIMER -> KEY_PU_FREEZE
            PowerUpType.MAGIC_WAND -> KEY_PU_WAND
        }
        it[key] = count
    }

    fun getPowerUpFlow(type: PowerUpType): Flow<Int> = when (type) {
        PowerUpType.SHUFFLE -> puShuffleFlow
        PowerUpType.COLOR_BOMB -> puColorBombFlow
        PowerUpType.UNDO_ALL -> puUndoAllFlow
        PowerUpType.FREEZE_TIMER -> puFreezeFlow
        PowerUpType.MAGIC_WAND -> puWandFlow
    }

    suspend fun resetAll() {
        context.dataStore.edit {
            it[KEY_HIGH_SCORE] = 0
            it[KEY_TOTAL_STARS] = 0
            it[KEY_GAMES_COMPLETED] = 0
            it[KEY_COINS] = 10
            it[KEY_PU_SHUFFLE] = 1
            it[KEY_PU_COLOR_BOMB] = 0
            it[KEY_PU_UNDO_ALL] = 2
            it[KEY_PU_FREEZE] = 0
            it[KEY_PU_WAND] = 0
        }
        sharedPrefs.edit().clear().apply()
    }
}
