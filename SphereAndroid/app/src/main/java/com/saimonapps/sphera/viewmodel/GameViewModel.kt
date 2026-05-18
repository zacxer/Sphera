package com.saimonapps.sphera.viewmodel

import android.app.Application
import android.content.Context
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.os.Build
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.saimonapps.sphera.models.*
import com.saimonapps.sphera.services.AudioManager
import com.saimonapps.sphera.services.L10n
import com.saimonapps.sphera.services.SettingsManager
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*

class GameViewModel(application: Application) : AndroidViewModel(application) {

    private val settings = SettingsManager.getInstance(application)
    private val audio = AudioManager.getInstance(application)

    // --- GameState ---
    private val _gameState = MutableStateFlow(GameState())
    val gameState: StateFlow<GameState> = _gameState.asStateFlow()

    private val _showWinAlert = MutableStateFlow(false)
    val showWinAlert: StateFlow<Boolean> = _showWinAlert.asStateFlow()

    private val _lastScore = MutableStateFlow(0)
    val lastScore: StateFlow<Int> = _lastScore.asStateFlow()

    private val _lastStars = MutableStateFlow(0)
    val lastStars: StateFlow<Int> = _lastStars.asStateFlow()

    private val _lastOptimalMoves = MutableStateFlow(0)
    val lastOptimalMoves: StateFlow<Int> = _lastOptimalMoves.asStateFlow()

    private val _lastCoinsEarned = MutableStateFlow(0)
    val lastCoinsEarned: StateFlow<Int> = _lastCoinsEarned.asStateFlow()

    private val _currentLevelData = MutableStateFlow<Level?>(null)
    val currentLevelData: StateFlow<Level?> = _currentLevelData.asStateFlow()

    // --- Undo ---
    private val _undoRemaining = MutableStateFlow(5)
    val undoRemaining: StateFlow<Int> = _undoRemaining.asStateFlow()
    private val maxFreeUndo = 5

    // --- Hint ---
    private val _hintRemaining = MutableStateFlow(2)
    val hintRemaining: StateFlow<Int> = _hintRemaining.asStateFlow()
    private val _hintSourceIndex = MutableStateFlow<Int?>(null)
    val hintSourceIndex: StateFlow<Int?> = _hintSourceIndex.asStateFlow()
    private val _hintDestIndex = MutableStateFlow<Int?>(null)
    val hintDestIndex: StateFlow<Int?> = _hintDestIndex.asStateFlow()
    private val _isShowingHint = MutableStateFlow(false)
    val isShowingHint: StateFlow<Boolean> = _isShowingHint.asStateFlow()
    private val maxFreeHints = 2

    // --- Animation ---
    private val _isAnimating = MutableStateFlow(false)
    val isAnimating: StateFlow<Boolean> = _isAnimating.asStateFlow()
    private val _animatingBall = MutableStateFlow<Ball?>(null)
    val animatingBall: StateFlow<Ball?> = _animatingBall.asStateFlow()
    private val _animationFromIndex = MutableStateFlow<Int?>(null)
    val animationFromIndex: StateFlow<Int?> = _animationFromIndex.asStateFlow()
    private val _animationToIndex = MutableStateFlow<Int?>(null)
    val animationToIndex: StateFlow<Int?> = _animationToIndex.asStateFlow()

    // --- Extra tube ---
    private var initialTubeCount = 0
    private val maxExtraTubes = 1

    // --- Invalid moves ---
    private val _invalidMovesCount = MutableStateFlow(0)
    val invalidMovesCount: StateFlow<Int> = _invalidMovesCount.asStateFlow()
    private val _showTooManyErrorsAlert = MutableStateFlow(false)
    val showTooManyErrorsAlert: StateFlow<Boolean> = _showTooManyErrorsAlert.asStateFlow()

    private val maxInvalidMoves: Int get() = when (currentDifficulty) {
        Difficulty.EASY -> 10; Difficulty.MEDIUM -> 5; Difficulty.HARD -> 3
    }

    // --- Timer ---
    private val _elapsedSeconds = MutableStateFlow(0)
    val elapsedSeconds: StateFlow<Int> = _elapsedSeconds.asStateFlow()
    private val _lastTimeBonusPercentage = MutableStateFlow(0)
    val lastTimeBonusPercentage: StateFlow<Int> = _lastTimeBonusPercentage.asStateFlow()
    private val _lastTimeBonus = MutableStateFlow(0)
    val lastTimeBonus: StateFlow<Int> = _lastTimeBonus.asStateFlow()
    private var timerJob: Job? = null

    // --- Freeze timer ---
    private val _isTimerFrozen = MutableStateFlow(false)
    val isTimerFrozen: StateFlow<Boolean> = _isTimerFrozen.asStateFlow()
    private val _frozenTimeRemaining = MutableStateFlow(0)
    val frozenTimeRemaining: StateFlow<Int> = _frozenTimeRemaining.asStateFlow()
    private var freezeJob: Job? = null

    // --- Power-up UI state ---
    private val _isSelectingColorBomb = MutableStateFlow(false)
    val isSelectingColorBomb: StateFlow<Boolean> = _isSelectingColorBomb.asStateFlow()
    private val _isSelectingMagicWand = MutableStateFlow(false)
    val isSelectingMagicWand: StateFlow<Boolean> = _isSelectingMagicWand.asStateFlow()
    private val _availableColorsForBomb = MutableStateFlow<List<BallColor>>(emptyList())
    val availableColorsForBomb: StateFlow<List<BallColor>> = _availableColorsForBomb.asStateFlow()
    private val _availableColorsForWand = MutableStateFlow<List<BallColor>>(emptyList())
    val availableColorsForWand: StateFlow<List<BallColor>> = _availableColorsForWand.asStateFlow()
    private val _showPowerUpPanel = MutableStateFlow(false)
    val showPowerUpPanel: StateFlow<Boolean> = _showPowerUpPanel.asStateFlow()
    private val _justCompletedTubeIndex = MutableStateFlow<Int?>(null)
    val justCompletedTubeIndex: StateFlow<Int?> = _justCompletedTubeIndex.asStateFlow()
    private val _showMagicWandNoSpaceAlert = MutableStateFlow(false)
    val showMagicWandNoSpaceAlert: StateFlow<Boolean> = _showMagicWandNoSpaceAlert.asStateFlow()

    // --- Coins/Power-up inventory (live from DataStore) ---
    val coinsFlow: StateFlow<Int> = settings.coinsFlow
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), 10)
    val puShuffleFlow: StateFlow<Int> = settings.puShuffleFlow
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), 1)
    val puColorBombFlow: StateFlow<Int> = settings.puColorBombFlow
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), 0)
    val puUndoAllFlow: StateFlow<Int> = settings.puUndoAllFlow
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), 2)
    val puFreezeFlow: StateFlow<Int> = settings.puFreezeFlow
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), 0)
    val puWandFlow: StateFlow<Int> = settings.puWandFlow
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), 0)

    // --- Settings flows ---
    val soundEnabled: StateFlow<Boolean> = settings.soundEnabled
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), true)
    val musicEnabled: StateFlow<Boolean> = settings.musicEnabled
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), true)
    val vibrationEnabled: StateFlow<Boolean> = settings.vibrationEnabled
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), true)
    val difficultyFlow: StateFlow<Difficulty> = settings.difficultyFlow
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), Difficulty.MEDIUM)
    val highScoreFlow: StateFlow<Int> = settings.highScoreFlow
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), 0)
    val totalStarsFlow: StateFlow<Int> = settings.totalStarsFlow
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), 0)
    val gamesCompletedFlow: StateFlow<Int> = settings.gamesCompletedFlow
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), 0)
    val languageFlow: StateFlow<String> = settings.languageFlow
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), "IT")

    private var currentDifficulty: Difficulty = Difficulty.MEDIUM
    private var initialGameState: GameState? = null
    private var currentLevelConfig: Level? = null
    private var hintJob: Job? = null

    private val targetTime: Int get() {
        val lvl = _gameState.value.currentLevel
        return when (currentDifficulty) {
            Difficulty.EASY -> 30 + lvl * 5
            Difficulty.MEDIUM -> 45 + lvl * 8
            Difficulty.HARD -> 60 + lvl * 10
        }
    }

    private val timeBonusPercentage: Int get() {
        val target = targetTime.toDouble()
        val elapsed = _elapsedSeconds.value.toDouble()
        return when {
            elapsed <= target * 0.5 -> 100
            elapsed <= target -> 50
            elapsed <= target * 1.5 -> 25
            else -> 0
        }
    }

    val formattedTime: String get() {
        val s = _elapsedSeconds.value
        return "${s / 60}:${"%02d".format(s % 60)}"
    }

    val canUndo: Boolean get() = _gameState.value.canUndo && _undoRemaining.value > 0
    val canShowHint: Boolean get() = _hintRemaining.value > 0 && !_isShowingHint.value
    val canAddExtraTube: Boolean get() {
        val extra = _gameState.value.tubes.size - initialTubeCount
        return extra < maxExtraTubes && _gameState.value.tubes.size < 10
    }

    init {
        viewModelScope.launch {
            settings.difficultyFlow.collect { diff ->
                currentDifficulty = diff
                L10n.isItalian = true
            }
        }
        viewModelScope.launch {
            settings.languageFlow.collect { lang ->
                L10n.isItalian = (lang == "IT")
            }
        }
        loadSavedLevel()
    }

    fun loadSavedLevel() {
        val level = settings.getLevelForDifficulty(currentDifficulty).let {
            if (it > 0) it else 1
        }
        startNewLevel(level)
    }

    fun changeDifficulty(d: Difficulty) {
        viewModelScope.launch {
            settings.setDifficulty(d)
            currentDifficulty = d
            loadSavedLevel()
        }
    }

    fun startNewLevel(level: Int) {
        val config = Level(level, currentDifficulty)
        currentLevelConfig = config
        _currentLevelData.value = config
        val tubes = config.generateTubes()
        initialTubeCount = tubes.size
        _gameState.value = GameState(tubes = tubes, moves = 0, currentLevel = level)
        _showWinAlert.value = false
        _lastScore.value = 0; _lastStars.value = 0; _lastCoinsEarned.value = 0
        _undoRemaining.value = maxFreeUndo
        _hintRemaining.value = maxFreeHints
        clearHint()
        _invalidMovesCount.value = 0
        _showTooManyErrorsAlert.value = false
        _elapsedSeconds.value = 0
        _lastTimeBonus.value = 0; _lastTimeBonusPercentage.value = 0
        _isTimerFrozen.value = false; _frozenTimeRemaining.value = 0
        _isSelectingColorBomb.value = false; _isSelectingMagicWand.value = false
        _showPowerUpPanel.value = false

        initialGameState = GameState(
            tubes = tubes.map { it.copy() },
            moves = 0,
            currentLevel = level
        )

        startTimer()
        settings.saveLevelForDifficulty(currentDifficulty, level)
    }

    // --- Timer ---

    private fun startTimer() {
        stopTimer()
        timerJob = viewModelScope.launch {
            while (true) {
                delay(1000)
                if (!_isTimerFrozen.value) _elapsedSeconds.value++
            }
        }
    }

    private fun stopTimer() {
        timerJob?.cancel(); timerJob = null
    }

    // --- Tube selection / movement ---

    fun selectTube(index: Int) {
        if (_isAnimating.value) return
        if (_gameState.value.isWon && !_showWinAlert.value) { handleWin(); return }
        if (_isShowingHint.value) clearHint()

        val state = _gameState.value
        val selected = state.selectedTubeIndex

        if (selected == null) {
            val (newState, result) = state.selectTube(index)
            if (result == MoveResult.SELECTED) {
                _gameState.value = newState
                audio.playSelectSound(); vibrate(VibrationStrength.MEDIUM)
            }
            return
        }

        if (selected == index) {
            _gameState.value = state.copy(selectedTubeIndex = null)
            vibrate(VibrationStrength.LIGHT)
            return
        }

        val ball = state.tubes[selected].topBall
        if (ball == null || !state.tubes[index].canReceiveBall(ball)) {
            _gameState.value = state.copy(selectedTubeIndex = null)
            audio.playErrorSound(); vibrate(VibrationStrength.HEAVY)
            handleInvalidMove()
            return
        }

        startMoveAnimation(selected, index, ball)
    }

    private fun startMoveAnimation(src: Int, dst: Int, ball: Ball) {
        _animatingBall.value = ball
        _animationFromIndex.value = src
        _animationToIndex.value = dst
        _isAnimating.value = true
        audio.playMoveSound(); vibrate(VibrationStrength.MEDIUM)

        viewModelScope.launch {
            delay(350)
            completeMoveAnimation()
        }
    }

    private fun completeMoveAnimation() {
        val src = _animationFromIndex.value ?: run { resetAnimation(); return }
        val dst = _animationToIndex.value ?: run { resetAnimation(); return }

        val wasComplete = _gameState.value.tubes[dst].isComplete
        val (newState, result) = _gameState.value.moveBall(src, dst)
        _gameState.value = newState

        if (!wasComplete && newState.tubes.getOrNull(dst)?.isComplete == true) {
            triggerTubeCompleteEffect(dst)
        }

        resetAnimation()

        if (result == MoveResult.WON || newState.isWon) {
            viewModelScope.launch {
                delay(150)
                if (_gameState.value.isWon && !_showWinAlert.value) handleWin()
            }
        }
    }

    private fun triggerTubeCompleteEffect(index: Int) {
        _justCompletedTubeIndex.value = index
        audio.playTubeCompleteSound(); vibrate(VibrationStrength.SUCCESS)
        viewModelScope.launch {
            delay(1500)
            _justCompletedTubeIndex.value = null
        }
    }

    private fun resetAnimation() {
        _isAnimating.value = false
        _animatingBall.value = null
        _animationFromIndex.value = null
        _animationToIndex.value = null
    }

    fun addEmptyTube() {
        if (!canAddExtraTube) return
        val tubes = _gameState.value.tubes + Tube()
        _gameState.value = _gameState.value.copy(tubes = tubes)
        vibrate(VibrationStrength.LIGHT)
    }

    // --- Invalid moves ---

    private fun handleInvalidMove() {
        _invalidMovesCount.value++
        if (_invalidMovesCount.value >= maxInvalidMoves) _showTooManyErrorsAlert.value = true
    }

    fun confirmRestartAfterErrors() {
        _showTooManyErrorsAlert.value = false
        restartLevel()
    }

    // --- Undo ---

    fun undo() {
        if (!canUndo) { audio.playErrorSound(); return }
        val (newState, ok) = _gameState.value.undoLastMove()
        if (ok) {
            _gameState.value = newState
            _undoRemaining.value--
            audio.playMoveSound(); vibrate(VibrationStrength.LIGHT)
        }
    }

    fun addExtraUndo(count: Int = 3) { _undoRemaining.value += count }

    // --- Hint ---

    fun showHint() {
        if (!canShowHint) { audio.playErrorSound(); return }
        val hint = findBestMove() ?: run { audio.playErrorSound(); return }
        _hintSourceIndex.value = hint.first
        _hintDestIndex.value = hint.second
        _isShowingHint.value = true
        _hintRemaining.value--
        vibrate(VibrationStrength.LIGHT)
        hintJob?.cancel()
        hintJob = viewModelScope.launch {
            delay(3000)
            clearHint()
        }
    }

    fun clearHint() {
        hintJob?.cancel(); hintJob = null
        _isShowingHint.value = false
        _hintSourceIndex.value = null
        _hintDestIndex.value = null
    }

    fun addExtraHints(count: Int = 2) { _hintRemaining.value += count }

    private fun findBestMove(): Pair<Int, Int>? {
        val tubes = _gameState.value.tubes
        for (si in tubes.indices) {
            if (tubes[si].isEmpty || tubes[si].isComplete || tubes[si].isTubeLocked || !tubes[si].canRemoveTop()) continue
            val top = tubes[si].topBall ?: continue
            for (di in tubes.indices) {
                if (si == di || tubes[di].isFull || tubes[di].isTubeLocked || tubes[di].isEmpty) continue
                if (tubes[di].canReceiveBall(top) && tubes[di].topBall?.ballColor == top.ballColor)
                    return Pair(si, di)
            }
        }
        for (si in tubes.indices) {
            if (tubes[si].isEmpty || tubes[si].isComplete || tubes[si].isTubeLocked || !tubes[si].canRemoveTop()) continue
            if (tubes[si].consecutiveTopBallsCount == tubes[si].balls.size) continue
            for (di in tubes.indices) {
                if (si == di || tubes[di].isTubeLocked || !tubes[di].isEmpty) continue
                return Pair(si, di)
            }
        }
        return null
    }

    // --- Win handling ---

    private fun handleWin() {
        stopTimer(); freezeJob?.cancel(); freezeJob = null
        val optimal = currentLevelConfig?.optimalMoves ?: (_gameState.value.currentLevel * 4)
        _lastOptimalMoves.value = optimal
        val stars = settings.calculateStars(_gameState.value.moves, optimal)
        _lastStars.value = stars
        viewModelScope.launch {
            val base = settings.addScore(
                _gameState.value.moves,
                _gameState.value.currentLevel,
                currentDifficulty,
                highScoreFlow.value
            )
            val bonusPct = timeBonusPercentage
            _lastTimeBonusPercentage.value = bonusPct
            val bonus = (base * bonusPct) / 100
            _lastTimeBonus.value = bonus
            _lastScore.value = base + bonus

            val coinsEarned = settings.calculateCoinsEarned(
                _gameState.value.currentLevel, stars, bonusPct > 0, currentDifficulty
            )
            _lastCoinsEarned.value = coinsEarned
            settings.addCoins(coinsEarned, coinsFlow.value)
        }
        _showWinAlert.value = true
        vibrate(VibrationStrength.SUCCESS)
    }

    fun nextLevel() {
        _showWinAlert.value = false
        val next = _gameState.value.currentLevel + 1
        viewModelScope.launch {
            delay(100)
            startNewLevel(next)
        }
    }

    fun restartLevel() { startNewLevel(_gameState.value.currentLevel) }

    fun resetAllProgress() {
        viewModelScope.launch {
            settings.resetAll()
            Difficulty.entries.forEach { settings.saveLevelForDifficulty(it, 1) }
            startNewLevel(1)
        }
    }

    // --- Power-ups ---

    fun togglePowerUpPanel() { _showPowerUpPanel.value = !_showPowerUpPanel.value }

    fun buyPowerUp(type: PowerUpType) {
        val cost = type.cost
        val coins = coinsFlow.value
        if (coins < cost) return
        viewModelScope.launch {
            settings.setCoins(coins - cost)
            val current = settings.getPowerUpFlow(type).first()
            settings.setPowerUpCount(type, current + 1)
        }
    }

    fun usePowerUp(type: PowerUpType) {
        viewModelScope.launch {
            val count = settings.getPowerUpFlow(type).first()
            if (count <= 0) return@launch
            when (type) {
                PowerUpType.UNDO_ALL -> applyUndoAll(count)
                PowerUpType.SHUFFLE -> applyShuffle(count)
                PowerUpType.FREEZE_TIMER -> applyFreezeTimer(count)
                PowerUpType.MAGIC_WAND -> prepareMagicWand(count)
                PowerUpType.COLOR_BOMB -> prepareColorBomb(count)
            }
        }
    }

    private suspend fun applyUndoAll(count: Int) {
        val initial = initialGameState ?: return
        _gameState.value = initial.copy()
        settings.setPowerUpCount(PowerUpType.UNDO_ALL, count - 1)
        _elapsedSeconds.value = 0
        startTimer()
        vibrate(VibrationStrength.MEDIUM)
    }

    private suspend fun applyShuffle(count: Int) {
        val state = _gameState.value
        val allBalls = state.tubes.flatMap { it.balls }.shuffled()
        var idx = 0
        val newTubes = state.tubes.map { tube ->
            val take = minOf(tube.balls.size, allBalls.size - idx)
            val sublist = allBalls.subList(idx, idx + take)
            idx += take
            tube.copy(balls = sublist)
        }
        _gameState.value = state.copy(tubes = newTubes)
        settings.setPowerUpCount(PowerUpType.SHUFFLE, count - 1)
        vibrate(VibrationStrength.MEDIUM)
    }

    private suspend fun applyFreezeTimer(count: Int) {
        _isTimerFrozen.value = true
        _frozenTimeRemaining.value = 30
        settings.setPowerUpCount(PowerUpType.FREEZE_TIMER, count - 1)
        freezeJob?.cancel()
        freezeJob = viewModelScope.launch {
            for (i in 29 downTo 0) {
                delay(1000)
                _frozenTimeRemaining.value = i
            }
            _isTimerFrozen.value = false
            _frozenTimeRemaining.value = 0
        }
        vibrate(VibrationStrength.LIGHT)
    }

    private suspend fun prepareMagicWand(count: Int) {
        val hasEmpty = _gameState.value.tubes.any { it.isEmpty && !it.isTubeLocked }
        if (!hasEmpty) { _showMagicWandNoSpaceAlert.value = true; return }
        val colors = _gameState.value.tubes
            .filter { !it.isEmpty && !it.isComplete }
            .mapNotNull { it.topBall?.ballColor }
            .distinct()
        _availableColorsForWand.value = colors
        _isSelectingMagicWand.value = true
    }

    fun applyMagicWand(color: BallColor) {
        _isSelectingMagicWand.value = false
        viewModelScope.launch {
            val count = settings.getPowerUpFlow(PowerUpType.MAGIC_WAND).first()
            val state = _gameState.value
            val tubeIdx = state.tubes.indexOfFirst { t ->
                !t.isEmpty && t.topBall?.ballColor == color && !t.isComplete
            }
            if (tubeIdx < 0) return@launch
            val tube = state.tubes[tubeIdx]
            val emptyIdx = state.tubes.indexOfFirst { it.isEmpty }
            if (emptyIdx < 0) return@launch
            val shape = tube.topBall?.shape ?: ShapeType.BALL
            val completedBalls = List(tube.capacity) { Ball(ballColor = color, shape = shape) }
            val newTubes = state.tubes.toMutableList()
            newTubes[tubeIdx] = tube.copy(balls = completedBalls)
            _gameState.value = state.copy(tubes = newTubes)
            settings.setPowerUpCount(PowerUpType.MAGIC_WAND, count - 1)
            triggerTubeCompleteEffect(tubeIdx)
            delay(150)
            if (_gameState.value.isWon) handleWin()
        }
    }

    fun dismissMagicWandNoSpace() { _showMagicWandNoSpaceAlert.value = false }

    private suspend fun prepareColorBomb(count: Int) {
        val colors = _gameState.value.tubes
            .filter { !it.isEmpty }
            .mapNotNull { it.topBall?.ballColor }
            .distinct()
        _availableColorsForBomb.value = colors
        _isSelectingColorBomb.value = true
    }

    fun applyColorBomb(color: BallColor) {
        _isSelectingColorBomb.value = false
        viewModelScope.launch {
            val count = settings.getPowerUpFlow(PowerUpType.COLOR_BOMB).first()
            val state = _gameState.value
            val newTubes = state.tubes.map { tube ->
                tube.copy(balls = tube.balls.filter { it.ballColor != color })
            }
            _gameState.value = state.copy(tubes = newTubes)
            settings.setPowerUpCount(PowerUpType.COLOR_BOMB, count - 1)
            vibrate(VibrationStrength.HEAVY)
            delay(150)
            if (_gameState.value.isWon) handleWin()
        }
    }

    fun cancelColorSelection() {
        _isSelectingColorBomb.value = false
        _isSelectingMagicWand.value = false
    }

    // --- Settings ---

    fun setSoundEnabled(v: Boolean) = viewModelScope.launch { settings.setSoundEnabled(v) }
    fun setMusicEnabled(v: Boolean) = viewModelScope.launch {
        settings.setMusicEnabled(v)
        if (v) audio.startMusic() else audio.stopMusic()
    }
    fun setVibrationEnabled(v: Boolean) = viewModelScope.launch { settings.setVibrationEnabled(v) }
    fun setLanguage(lang: String) = viewModelScope.launch {
        settings.setLanguage(lang)
        L10n.isItalian = (lang == "IT")
    }

    // --- Rewarded ad ---
    fun onRewardedAdCoins(amount: Int = 25) = viewModelScope.launch {
        settings.addCoins(amount, coinsFlow.value)
    }

    // --- Tester ---
    fun jumpToLevel(level: Int) { startNewLevel(maxOf(1, level)) }

    // --- Vibration ---

    private enum class VibrationStrength { LIGHT, MEDIUM, HEAVY, SUCCESS }

    private fun vibrate(strength: VibrationStrength) {
        if (!vibrationEnabled.value) return
        val ctx = getApplication<Application>()
        val vib = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            (ctx.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager).defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            ctx.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }
        val ms = when (strength) {
            VibrationStrength.LIGHT -> 30L
            VibrationStrength.MEDIUM -> 60L
            VibrationStrength.HEAVY -> 100L
            VibrationStrength.SUCCESS -> 80L
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vib.vibrate(VibrationEffect.createOneShot(ms, VibrationEffect.DEFAULT_AMPLITUDE))
        } else {
            @Suppress("DEPRECATION")
            vib.vibrate(ms)
        }
    }

    override fun onCleared() {
        super.onCleared()
        stopTimer()
        freezeJob?.cancel()
        hintJob?.cancel()
    }
}

