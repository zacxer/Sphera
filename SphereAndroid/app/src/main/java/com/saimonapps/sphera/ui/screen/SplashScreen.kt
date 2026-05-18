package com.saimonapps.sphera.ui.screen

import androidx.compose.animation.core.*
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.scale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.saimonapps.sphera.ui.theme.*
import kotlinx.coroutines.delay

@Composable
fun SplashScreen(onFinished: () -> Unit) {
    val scale by rememberInfiniteTransition(label = "splash").animateFloat(
        initialValue = 0.8f,
        targetValue = 1.1f,
        animationSpec = infiniteRepeatable(tween(1000, easing = EaseInOutCubic), RepeatMode.Reverse),
        label = "scale"
    )

    LaunchedEffect(Unit) {
        delay(1800)
        onFinished()
    }

    AnimatedBackground {
        Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text(
                    "⚪🟡🔴🔵",
                    fontSize = 48.sp,
                    modifier = Modifier.scale(scale)
                )
                Spacer(Modifier.height(16.dp))
                Text(
                    "SPHERA",
                    fontWeight = FontWeight.Bold,
                    fontSize = 42.sp,
                    color = AccentGold,
                    letterSpacing = 6.sp
                )
                Text(
                    "BALL SORT PUZZLE",
                    fontSize = 14.sp,
                    color = TextSecondary,
                    letterSpacing = 3.sp
                )
            }
        }
    }
}
