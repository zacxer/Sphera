package com.saimonapps.sphera.ui.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.saimonapps.sphera.models.Difficulty
import com.saimonapps.sphera.services.L10n
import com.saimonapps.sphera.ui.theme.*
import com.saimonapps.sphera.viewmodel.GameViewModel

@Composable
fun MenuScreen(
    vm: GameViewModel,
    onPlay: () -> Unit,
    onSettings: () -> Unit
) {
    val difficulty by vm.difficultyFlow.collectAsStateWithLifecycle()
    val highScore by vm.highScoreFlow.collectAsStateWithLifecycle()
    val totalStars by vm.totalStarsFlow.collectAsStateWithLifecycle()
    val gamesCompleted by vm.gamesCompletedFlow.collectAsStateWithLifecycle()
    val coins by vm.coinsFlow.collectAsStateWithLifecycle()

    AnimatedBackground {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.SpaceBetween
        ) {
            Spacer(Modifier.height(32.dp))

            // Title
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text("⚪🟡🔴🔵", fontSize = 36.sp)
                Spacer(Modifier.height(8.dp))
                Text("SPHERA", fontWeight = FontWeight.Bold, fontSize = 40.sp, color = AccentGold, letterSpacing = 5.sp)
                Text("BALL SORT PUZZLE", fontSize = 12.sp, color = TextSecondary, letterSpacing = 3.sp)
            }

            // Stats card
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(12.dp))
                    .background(SurfaceCard)
                    .padding(12.dp),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                StatItem("⭐", "$totalStars", L10n.stars)
                StatItem("🏆", "$highScore", L10n.record)
                StatItem("✅", "$gamesCompleted", L10n.completed)
                StatItem("🪙", "$coins", L10n.coins)
            }

            // Difficulty selector
            Column(modifier = Modifier.fillMaxWidth()) {
                Text(L10n.difficulty, color = TextSecondary, fontSize = 12.sp, fontWeight = FontWeight.Medium)
                Spacer(Modifier.height(6.dp))
                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                    Difficulty.entries.forEach { d ->
                        DifficultyChip(
                            label = when (d) {
                                Difficulty.EASY -> L10n.easy
                                Difficulty.MEDIUM -> L10n.medium
                                Difficulty.HARD -> L10n.hard
                            },
                            selected = difficulty == d,
                            color = when (d) {
                                Difficulty.EASY -> BallGreen
                                Difficulty.MEDIUM -> BallYellow
                                Difficulty.HARD -> BallRed
                            },
                            modifier = Modifier.weight(1f),
                            onClick = { vm.changeDifficulty(d) }
                        )
                    }
                }
            }

            // Play button
            Button(
                onClick = onPlay,
                modifier = Modifier.fillMaxWidth().height(56.dp),
                colors = ButtonDefaults.buttonColors(containerColor = AccentGold),
                shape = RoundedCornerShape(16.dp)
            ) {
                Text(L10n.play, color = BgDeep, fontWeight = FontWeight.ExtraBold, fontSize = 20.sp, letterSpacing = 2.sp)
            }

            // Settings
            TextButton(onClick = onSettings) {
                Text("⚙ ${L10n.settings}", color = TextSecondary)
            }

            Spacer(Modifier.height(16.dp))
        }
    }
}

@Composable
private fun StatItem(icon: String, value: String, label: String) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(icon, fontSize = 18.sp)
        Text(value, fontWeight = FontWeight.Bold, color = AccentGold, fontSize = 14.sp)
        Text(label, color = TextSecondary, fontSize = 10.sp)
    }
}

@Composable
private fun DifficultyChip(
    label: String, selected: Boolean, color: Color,
    modifier: Modifier, onClick: () -> Unit
) {
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(8.dp))
            .background(if (selected) color.copy(alpha = 0.25f) else SurfaceCard)
            .border(1.5.dp, if (selected) color else Color.Transparent, RoundedCornerShape(8.dp))
            .clickable(onClick = onClick)
            .padding(vertical = 8.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(label, color = if (selected) color else TextSecondary, fontWeight = if (selected) FontWeight.Bold else FontWeight.Normal, fontSize = 13.sp)
    }
}
