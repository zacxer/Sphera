package com.saimonapps.sphera.ui.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.saimonapps.sphera.BuildConfig
import com.saimonapps.sphera.models.BallColor
import com.saimonapps.sphera.services.L10n
import com.saimonapps.sphera.ui.ads.BannerAdView
import com.saimonapps.sphera.ui.game.*
import com.saimonapps.sphera.ui.theme.*
import com.saimonapps.sphera.viewmodel.GameViewModel

@Composable
fun GameScreen(
    vm: GameViewModel,
    onBackToMenu: () -> Unit
) {
    val gameState by vm.gameState.collectAsStateWithLifecycle()
    val showWin by vm.showWinAlert.collectAsStateWithLifecycle()
    val showErrors by vm.showTooManyErrorsAlert.collectAsStateWithLifecycle()
    val hintSrc by vm.hintSourceIndex.collectAsStateWithLifecycle()
    val hintDst by vm.hintDestIndex.collectAsStateWithLifecycle()
    val completedIdx by vm.justCompletedTubeIndex.collectAsStateWithLifecycle()
    val undoRem by vm.undoRemaining.collectAsStateWithLifecycle()
    val hintRem by vm.hintRemaining.collectAsStateWithLifecycle()
    val coins by vm.coinsFlow.collectAsStateWithLifecycle()
    val showShop by vm.showPowerUpPanel.collectAsStateWithLifecycle()
    val levelData by vm.currentLevelData.collectAsStateWithLifecycle()
    val isTimerFrozen by vm.isTimerFrozen.collectAsStateWithLifecycle()
    val frozenRemaining by vm.frozenTimeRemaining.collectAsStateWithLifecycle()
    val isSelectingBomb by vm.isSelectingColorBomb.collectAsStateWithLifecycle()
    val isSelectingWand by vm.isSelectingMagicWand.collectAsStateWithLifecycle()
    val bombColors by vm.availableColorsForBomb.collectAsStateWithLifecycle()
    val wandColors by vm.availableColorsForWand.collectAsStateWithLifecycle()
    val showWandNoSpace by vm.showMagicWandNoSpaceAlert.collectAsStateWithLifecycle()
    val puShuffle by vm.puShuffleFlow.collectAsStateWithLifecycle()
    val puBomb by vm.puColorBombFlow.collectAsStateWithLifecycle()
    val puUndo by vm.puUndoAllFlow.collectAsStateWithLifecycle()
    val puFreeze by vm.puFreezeFlow.collectAsStateWithLifecycle()
    val puWand by vm.puWandFlow.collectAsStateWithLifecycle()
    val lastStars by vm.lastStars.collectAsStateWithLifecycle()
    val lastScore by vm.lastScore.collectAsStateWithLifecycle()
    val lastOptimal by vm.lastOptimalMoves.collectAsStateWithLifecycle()
    val lastBonus by vm.lastTimeBonus.collectAsStateWithLifecycle()
    val lastBonusPct by vm.lastTimeBonusPercentage.collectAsStateWithLifecycle()
    val lastCoins by vm.lastCoinsEarned.collectAsStateWithLifecycle()

    var showTester by remember { mutableStateOf(false) }
    var showShapesTutorial by remember { mutableStateOf(false) }

    LaunchedEffect(levelData?.number) {
        if (levelData?.isFirstShapeIntroduction == true) {
            showShapesTutorial = true
        }
    }

    AnimatedBackground {
        Column(modifier = Modifier.fillMaxSize()) {
            // Header
            GameHeader(
                level = gameState.currentLevel,
                moves = gameState.moves,
                time = vm.formattedTime,
                isTimerFrozen = isTimerFrozen,
                frozenRemaining = frozenRemaining,
                onBack = onBackToMenu,
                onTesterLongPress = { if (BuildConfig.DEBUG) showTester = true }
            )

            // Game board
            Box(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth(),
                contentAlignment = Alignment.Center
            ) {
                GameBoard(
                    gameState = gameState,
                    selectedIndex = gameState.selectedTubeIndex,
                    hintSourceIndex = hintSrc,
                    hintDestIndex = hintDst,
                    justCompletedIndex = completedIdx,
                    onTubeTap = { vm.selectTube(it) }
                )
            }

            // Power-up bar
            PowerUpBar(
                coins = coins,
                undoRemaining = undoRem,
                hintRemaining = hintRem,
                canAddExtraTube = vm.canAddExtraTube,
                onUndo = { vm.undo() },
                onHint = { vm.showHint() },
                onExtraTube = { vm.addEmptyTube() },
                onOpenShop = { vm.togglePowerUpPanel() }
            )

            // Banner ad
            BannerAdView()
        }
    }

    // Color selection for bomb / wand
    if (isSelectingBomb) {
        ColorSelectionDialog(
            title = L10n.powerUpColorBomb,
            colors = bombColors,
            onSelect = { vm.applyColorBomb(it) },
            onCancel = { vm.cancelColorSelection() }
        )
    }
    if (isSelectingWand) {
        ColorSelectionDialog(
            title = L10n.powerUpMagicWand,
            colors = wandColors,
            onSelect = { vm.applyMagicWand(it) },
            onCancel = { vm.cancelColorSelection() }
        )
    }

    // Win dialog
    if (showWin) {
        WinDialog(
            level = gameState.currentLevel,
            stars = lastStars,
            moves = gameState.moves,
            optimalMoves = lastOptimal,
            score = lastScore,
            timeBonus = lastBonus,
            timeBonusPct = lastBonusPct,
            coinsEarned = lastCoins,
            formattedTime = vm.formattedTime,
            onNextLevel = { vm.nextLevel() },
            onRestart = { vm.restartLevel() }
        )
    }

    // Too many errors
    if (showErrors) {
        TooManyErrorsDialog(
            errorCount = vm.invalidMovesCount.collectAsStateWithLifecycle().value,
            maxErrors = 5,
            onRestart = { vm.confirmRestartAfterErrors() },
            onDismiss = { vm.confirmRestartAfterErrors() }
        )
    }

    // Shapes tutorial
    if (showShapesTutorial) {
        ShapesTutorialDialog(onDismiss = { showShapesTutorial = false })
    }

    // Power-up shop
    if (showShop) {
        val puCounts = mapOf(
            com.saimonapps.sphera.models.PowerUpType.SHUFFLE to puShuffle,
            com.saimonapps.sphera.models.PowerUpType.COLOR_BOMB to puBomb,
            com.saimonapps.sphera.models.PowerUpType.UNDO_ALL to puUndo,
            com.saimonapps.sphera.models.PowerUpType.FREEZE_TIMER to puFreeze,
            com.saimonapps.sphera.models.PowerUpType.MAGIC_WAND to puWand,
        )
        PowerUpShop(
            coins = coins,
            puCounts = puCounts,
            onBuy = { vm.buyPowerUp(it) },
            onUse = { vm.usePowerUp(it) },
            onDismiss = { vm.togglePowerUpPanel() }
        )
    }

    // Tester panel (DEBUG only)
    if (showTester) {
        TesterPanel(vm = vm, onDismiss = { showTester = false })
    }

    // Magic wand no space alert
    if (showWandNoSpace) {
        androidx.compose.material3.AlertDialog(
            onDismissRequest = { vm.dismissMagicWandNoSpace() },
            containerColor = BgMid,
            title = { Text(L10n.magicWandNoSpace, color = TextPrimary) },
            text = { Text("Free up a tube first", color = TextSecondary) },
            confirmButton = {
                androidx.compose.material3.TextButton(onClick = { vm.dismissMagicWandNoSpace() }) {
                    Text(L10n.close, color = AccentGold)
                }
            }
        )
    }
}

@Composable
private fun GameHeader(
    level: Int,
    moves: Int,
    time: String,
    isTimerFrozen: Boolean,
    frozenRemaining: Int,
    onBack: () -> Unit,
    onTesterLongPress: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(SurfaceCard)
            .padding(horizontal = 12.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Text("←", modifier = Modifier.clickable(onClick = onBack), color = TextSecondary, fontSize = 22.sp)

        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text("${L10n.level} $level", fontWeight = FontWeight.Bold, color = AccentGold, fontSize = 16.sp)
            Text("$moves ${L10n.moves}", color = TextSecondary, fontSize = 11.sp)
        }

        Column(
            horizontalAlignment = Alignment.End,
            modifier = Modifier.clickable(onClick = onTesterLongPress)
        ) {
            val timeColor = if (isTimerFrozen) TubeFrozenAccent else TextPrimary
            Text(if (isTimerFrozen) "❄ $frozenRemaining" else time, color = timeColor, fontWeight = FontWeight.Bold, fontSize = 16.sp)
            Text(L10n.time, color = TextSecondary, fontSize = 11.sp)
        }
    }
}

@Composable
private fun ColorSelectionDialog(
    title: String,
    colors: List<BallColor>,
    onSelect: (BallColor) -> Unit,
    onCancel: () -> Unit
) {
    androidx.compose.ui.window.Dialog(onDismissRequest = onCancel) {
        Column(
            modifier = Modifier
                .clip(RoundedCornerShape(20.dp))
                .background(BgMid)
                .padding(20.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(title, fontWeight = FontWeight.Bold, color = AccentGold, fontSize = 16.sp)
            Text(L10n.selectColor, color = TextSecondary, fontSize = 12.sp)
            Spacer(Modifier.height(12.dp))
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.fillMaxWidth()) {
                colors.forEach { color ->
                    Box(
                        modifier = Modifier
                            .size(44.dp)
                            .clip(RoundedCornerShape(10.dp))
                            .background(color.color)
                            .clickable { onSelect(color) }
                    )
                }
            }
            Spacer(Modifier.height(8.dp))
            androidx.compose.material3.TextButton(onClick = onCancel) {
                Text(L10n.cancel, color = TextSecondary)
            }
        }
    }
}
