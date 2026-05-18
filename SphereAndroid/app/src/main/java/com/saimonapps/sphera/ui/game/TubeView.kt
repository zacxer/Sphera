package com.saimonapps.sphera.ui.game

import androidx.compose.animation.core.*
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import com.saimonapps.sphera.models.*
import com.saimonapps.sphera.ui.theme.*

@Composable
fun TubeView(
    tube: Tube,
    isSelected: Boolean,
    isHintSource: Boolean,
    isHintDest: Boolean,
    isJustCompleted: Boolean,
    ballSize: Dp = 36.dp,
    onTap: () -> Unit,
    modifier: Modifier = Modifier
) {
    val borderColor = when {
        isSelected -> AccentGold
        isHintSource -> Color(0xFF00E5FF)
        isHintDest -> Color(0xFF69FF47)
        tube.isComplete -> AccentGold
        else -> tube.type.accentColor.takeIf { it != Color.Transparent }
            ?: SurfaceElevated
    }
    val borderWidth = if (isSelected || isHintSource || isHintDest) 2.5.dp else 1.5.dp

    val completePulse by rememberInfiniteTransition(label = "pulse").animateFloat(
        initialValue = 1f, targetValue = 1.05f,
        animationSpec = infiniteRepeatable(tween(600), RepeatMode.Reverse),
        label = "scale"
    )
    val scale = if (isSelected) 1.05f else if (isJustCompleted) completePulse else 1f

    Column(
        modifier = modifier
            .scale(scale)
            .clip(RoundedCornerShape(bottomStart = 16.dp, bottomEnd = 16.dp, topStart = 6.dp, topEnd = 6.dp))
            .background(
                if (tube.isComplete) AccentGold.copy(alpha = 0.15f) else SurfaceCard
            )
            .border(borderWidth, borderColor, RoundedCornerShape(bottomStart = 16.dp, bottomEnd = 16.dp, topStart = 6.dp, topEnd = 6.dp))
            .clickable(enabled = !tube.isTubeLocked) { onTap() }
            .padding(horizontal = 4.dp, vertical = 4.dp)
            .width(ballSize + 8.dp)
            .height(ballSize * tube.capacity + 16.dp),
        verticalArrangement = Arrangement.Bottom,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        if (tube.isTubeLocked) {
            Spacer(Modifier.weight(1f))
            Text("🔒", fontSize = 20.sp, modifier = Modifier.padding(bottom = 4.dp))
        } else {
            val emptySlots = tube.capacity - tube.balls.size
            repeat(emptySlots) { Spacer(Modifier.height(ballSize + 2.dp)) }
            tube.balls.forEachIndexed { idx, ball ->
                val isFrozenTop = tube.isTopBallFrozen && idx == tube.balls.lastIndex
                Box {
                    BallView(ball = ball, size = ballSize)
                    if (isFrozenTop) {
                        Text(
                            "❄",
                            fontSize = (ballSize.value * 0.4f).sp,
                            modifier = Modifier.align(Alignment.TopEnd)
                        )
                    }
                }
                if (idx < tube.balls.lastIndex) Spacer(Modifier.height(2.dp))
            }
        }

        if (tube.type == TubeType.FROZEN && (tube.freezeCountdown ?: 0) > 0) {
            Text(
                "${tube.freezeCountdown}",
                fontSize = 10.sp,
                fontWeight = FontWeight.Bold,
                color = TubeFrozenAccent
            )
        }
    }
}
