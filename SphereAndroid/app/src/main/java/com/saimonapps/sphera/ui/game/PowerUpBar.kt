package com.saimonapps.sphera.ui.game

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.saimonapps.sphera.services.L10n
import com.saimonapps.sphera.ui.theme.*

@Composable
fun PowerUpBar(
    coins: Int,
    undoRemaining: Int,
    hintRemaining: Int,
    canAddExtraTube: Boolean,
    onUndo: () -> Unit,
    onHint: () -> Unit,
    onExtraTube: () -> Unit,
    onOpenShop: () -> Unit,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 12.dp, vertical = 6.dp),
        horizontalArrangement = Arrangement.SpaceEvenly,
        verticalAlignment = Alignment.CenterVertically
    ) {
        ActionButton(
            icon = "↩",
            label = L10n.undo,
            badge = undoRemaining.toString(),
            onClick = onUndo
        )
        ActionButton(
            icon = "💡",
            label = L10n.hint,
            badge = hintRemaining.toString(),
            onClick = onHint
        )
        if (canAddExtraTube) {
            ActionButton(
                icon = "➕",
                label = L10n.extraTube,
                badge = null,
                onClick = onExtraTube
            )
        }
        CoinsButton(coins = coins, onClick = onOpenShop)
    }
}

@Composable
private fun ActionButton(
    icon: String,
    label: String,
    badge: String?,
    onClick: () -> Unit
) {
    Box(contentAlignment = Alignment.TopEnd) {
        Column(
            modifier = Modifier
                .clip(RoundedCornerShape(10.dp))
                .background(SurfaceElevated)
                .clickable(onClick = onClick)
                .padding(horizontal = 10.dp, vertical = 6.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(icon, fontSize = 22.sp)
            Text(label, fontSize = 10.sp, color = TextSecondary)
        }
        if (badge != null) {
            Text(
                badge,
                modifier = Modifier
                    .clip(CircleShape)
                    .background(AccentGold)
                    .padding(horizontal = 5.dp, vertical = 1.dp),
                fontSize = 9.sp,
                fontWeight = FontWeight.Bold,
                color = BgDeep
            )
        }
    }
}

@Composable
private fun CoinsButton(coins: Int, onClick: () -> Unit) {
    Row(
        modifier = Modifier
            .clip(RoundedCornerShape(10.dp))
            .background(SurfaceElevated)
            .clickable(onClick = onClick)
            .padding(horizontal = 12.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        Text("🪙", fontSize = 16.sp)
        Text(coins.toString(), fontWeight = FontWeight.Bold, color = AccentGold, fontSize = 14.sp)
    }
}
