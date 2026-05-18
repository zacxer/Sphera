package com.saimonapps.sphera.ui.game

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import com.saimonapps.sphera.services.L10n
import com.saimonapps.sphera.ui.theme.*

@Composable
fun WinDialog(
    level: Int,
    stars: Int,
    moves: Int,
    optimalMoves: Int,
    score: Int,
    timeBonus: Int,
    timeBonusPct: Int,
    coinsEarned: Int,
    formattedTime: String,
    onNextLevel: () -> Unit,
    onRestart: () -> Unit
) {
    Dialog(onDismissRequest = {}) {
        Column(
            modifier = Modifier
                .clip(RoundedCornerShape(20.dp))
                .background(BgMid)
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(L10n.fantastic, fontWeight = FontWeight.Bold, fontSize = 28.sp, color = AccentGold)
            Text(
                L10n.levelCompleted.format(level),
                color = TextSecondary,
                fontSize = 14.sp
            )

            Spacer(Modifier.height(12.dp))

            // Stars
            Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                repeat(3) { i ->
                    Text(
                        if (i < stars) "⭐" else "☆",
                        fontSize = 28.sp
                    )
                }
            }

            Spacer(Modifier.height(16.dp))

            // Stats
            ScoreRow(L10n.yourMoves, "$moves")
            ScoreRow(L10n.minMoves, "$optimalMoves")
            ScoreRow(L10n.time, formattedTime)
            if (timeBonusPct > 0) ScoreRow(L10n.timeBonus, "+$timeBonusPct%  +$timeBonus")
            HorizontalDivider(Modifier.padding(vertical = 4.dp), color = SurfaceElevated)
            ScoreRow(L10n.totalScore, "$score ${L10n.points}", highlight = true)
            if (coinsEarned > 0) ScoreRow("🪙 ${L10n.coins}", "+$coinsEarned")

            Spacer(Modifier.height(16.dp))

            Button(
                onClick = onNextLevel,
                modifier = Modifier.fillMaxWidth(),
                colors = ButtonDefaults.buttonColors(containerColor = AccentGold)
            ) {
                Text(L10n.nextLevel, color = BgDeep, fontWeight = FontWeight.Bold)
            }
            Spacer(Modifier.height(6.dp))
            Button(
                onClick = onRestart,
                modifier = Modifier.fillMaxWidth(),
                colors = ButtonDefaults.buttonColors(containerColor = SurfaceElevated)
            ) {
                Text(L10n.restart, color = TextSecondary)
            }
        }
    }
}

@Composable
private fun ScoreRow(label: String, value: String, highlight: Boolean = false) {
    Row(
        modifier = Modifier.fillMaxWidth().padding(vertical = 2.dp),
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Text(label, color = if (highlight) TextPrimary else TextSecondary, fontWeight = if (highlight) FontWeight.Bold else FontWeight.Normal, fontSize = 13.sp)
        Text(value, color = if (highlight) AccentGold else TextPrimary, fontWeight = if (highlight) FontWeight.Bold else FontWeight.Normal, fontSize = 13.sp)
    }
}
