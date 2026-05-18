package com.saimonapps.sphera.ui.game

import androidx.compose.foundation.layout.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.saimonapps.sphera.models.GameState

@Composable
fun GameBoard(
    gameState: GameState,
    selectedIndex: Int?,
    hintSourceIndex: Int?,
    hintDestIndex: Int?,
    justCompletedIndex: Int?,
    onTubeTap: (Int) -> Unit,
    modifier: Modifier = Modifier
) {
    val tubeCount = gameState.tubes.size
    val columns = when {
        tubeCount <= 4 -> 4
        tubeCount <= 6 -> 3
        tubeCount <= 8 -> 4
        else -> 5
    }
    val maxCapacity = gameState.tubes.maxOfOrNull { it.capacity } ?: 4
    val ballSize: Dp = when {
        tubeCount >= 10 -> 28.dp
        tubeCount >= 8 -> 30.dp
        else -> 34.dp
    }

    Column(modifier = modifier, horizontalAlignment = Alignment.CenterHorizontally) {
        val rows = (tubeCount + columns - 1) / columns
        for (row in 0 until rows) {
            Row(
                horizontalArrangement = Arrangement.Center,
                modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp)
            ) {
                for (col in 0 until columns) {
                    val idx = row * columns + col
                    if (idx < tubeCount) {
                        TubeView(
                            tube = gameState.tubes[idx],
                            isSelected = selectedIndex == idx,
                            isHintSource = hintSourceIndex == idx,
                            isHintDest = hintDestIndex == idx,
                            isJustCompleted = justCompletedIndex == idx,
                            ballSize = ballSize,
                            onTap = { onTubeTap(idx) },
                            modifier = Modifier.padding(horizontal = 3.dp)
                        )
                    } else {
                        Spacer(Modifier.width(ballSize + 16.dp).padding(horizontal = 3.dp))
                    }
                }
            }
        }
    }
}
