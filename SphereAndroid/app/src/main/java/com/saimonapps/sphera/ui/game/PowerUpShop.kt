package com.saimonapps.sphera.ui.game

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.material3.HorizontalDivider
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.saimonapps.sphera.models.PowerUpType
import com.saimonapps.sphera.services.L10n
import com.saimonapps.sphera.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PowerUpShop(
    coins: Int,
    puCounts: Map<PowerUpType, Int>,
    onBuy: (PowerUpType) -> Unit,
    onUse: (PowerUpType) -> Unit,
    onDismiss: () -> Unit
) {
    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = BgMid,
        tonalElevation = 0.dp
    ) {
        Column(modifier = Modifier.fillMaxWidth().padding(16.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(L10n.powerUps, fontWeight = FontWeight.Bold, fontSize = 18.sp, color = TextPrimary)
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    Text("🪙", fontSize = 16.sp)
                    Text(coins.toString(), fontWeight = FontWeight.Bold, color = AccentGold)
                }
            }

            Spacer(Modifier.height(12.dp))

            LazyColumn(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                items(PowerUpType.entries) { type ->
                    PowerUpRow(
                        type = type,
                        count = puCounts[type] ?: 0,
                        coins = coins,
                        onBuy = { onBuy(type) },
                        onUse = { onUse(type) }
                    )
                }
            }

            HorizontalDivider(modifier = Modifier.padding(vertical = 12.dp), color = SurfaceElevated)

            // Rewarded ad section
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(10.dp))
                    .background(SurfaceCard)
                    .padding(12.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Column {
                    Text(L10n.watchAdForCoins, fontWeight = FontWeight.Medium, color = TextPrimary, fontSize = 14.sp)
                }
                Text("+25 🪙", color = AccentGold, fontWeight = FontWeight.Bold)
            }

            Spacer(Modifier.height(16.dp))
        }
    }
}

@Composable
private fun PowerUpRow(
    type: PowerUpType,
    count: Int,
    coins: Int,
    onBuy: () -> Unit,
    onUse: () -> Unit
) {
    val name = when (type) {
        PowerUpType.SHUFFLE -> L10n.powerUpShuffle
        PowerUpType.COLOR_BOMB -> L10n.powerUpColorBomb
        PowerUpType.UNDO_ALL -> L10n.powerUpUndoAll
        PowerUpType.FREEZE_TIMER -> L10n.powerUpFreezeTimer
        PowerUpType.MAGIC_WAND -> L10n.powerUpMagicWand
    }
    val desc = when (type) {
        PowerUpType.SHUFFLE -> L10n.powerUpShuffleDesc
        PowerUpType.COLOR_BOMB -> L10n.powerUpColorBombDesc
        PowerUpType.UNDO_ALL -> L10n.powerUpUndoAllDesc
        PowerUpType.FREEZE_TIMER -> L10n.powerUpFreezeTimerDesc
        PowerUpType.MAGIC_WAND -> L10n.powerUpMagicWandDesc
    }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(10.dp))
            .background(SurfaceCard)
            .padding(10.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.weight(1f)) {
            Box(
                modifier = Modifier
                    .size(36.dp)
                    .clip(RoundedCornerShape(8.dp))
                    .background(type.color.copy(alpha = 0.2f)),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    when (type) {
                        PowerUpType.SHUFFLE -> "🔀"; PowerUpType.COLOR_BOMB -> "💣"
                        PowerUpType.UNDO_ALL -> "↩"; PowerUpType.FREEZE_TIMER -> "❄"
                        PowerUpType.MAGIC_WAND -> "🪄"
                    },
                    fontSize = 18.sp
                )
            }
            Spacer(Modifier.width(8.dp))
            Column {
                Text(name, fontWeight = FontWeight.SemiBold, color = TextPrimary, fontSize = 13.sp)
                Text(desc, color = TextSecondary, fontSize = 11.sp, lineHeight = 14.sp)
            }
        }
        Spacer(Modifier.width(8.dp))
        Column(horizontalAlignment = Alignment.End, verticalArrangement = Arrangement.spacedBy(4.dp)) {
            if (count > 0) {
                Text("×$count", color = AccentGold, fontSize = 12.sp)
                Button(
                    onClick = onUse,
                    colors = ButtonDefaults.buttonColors(containerColor = type.color),
                    contentPadding = PaddingValues(horizontal = 10.dp, vertical = 4.dp),
                    modifier = Modifier.height(28.dp)
                ) {
                    Text(L10n.use, fontSize = 11.sp)
                }
            }
            Button(
                onClick = onBuy,
                enabled = coins >= type.cost,
                colors = ButtonDefaults.buttonColors(containerColor = SurfaceElevated),
                contentPadding = PaddingValues(horizontal = 8.dp, vertical = 4.dp),
                modifier = Modifier.height(28.dp)
            ) {
                Text("${type.cost}🪙", fontSize = 11.sp, color = if (coins >= type.cost) AccentGold else TextSecondary)
            }
        }
    }
}
