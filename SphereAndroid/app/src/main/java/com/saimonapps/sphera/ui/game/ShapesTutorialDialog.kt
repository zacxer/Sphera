package com.saimonapps.sphera.ui.game

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import com.saimonapps.sphera.models.*
import com.saimonapps.sphera.services.L10n
import com.saimonapps.sphera.ui.theme.*

@Composable
fun ShapesTutorialDialog(onDismiss: () -> Unit) {
    Dialog(onDismissRequest = onDismiss) {
        Column(
            modifier = Modifier
                .clip(RoundedCornerShape(20.dp))
                .background(BgMid)
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text("✨", fontSize = 36.sp)
            Spacer(Modifier.height(8.dp))
            Text(L10n.shapesTutorialTitle, fontWeight = FontWeight.Bold, fontSize = 22.sp, color = AccentGold)
            Text(L10n.shapesTutorialSubtitle, color = TextSecondary, fontSize = 13.sp, textAlign = TextAlign.Center)
            Spacer(Modifier.height(16.dp))

            // Show all shapes
            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                ShapeType.entries.forEach { shape ->
                    BallView(ball = Ball(ballColor = BallColor.BLUE, shape = shape), size = 32.dp)
                }
            }

            Spacer(Modifier.height(16.dp))

            RuleCard(icon = "✅", text = L10n.shapesTutorialRule1)
            Spacer(Modifier.height(6.dp))
            RuleCard(icon = "🎯", text = L10n.shapesTutorialRule2)

            Spacer(Modifier.height(16.dp))

            Button(
                onClick = onDismiss,
                modifier = Modifier.fillMaxWidth(),
                colors = ButtonDefaults.buttonColors(containerColor = AccentGold)
            ) {
                Text(L10n.shapesTutorialGotIt, color = BgDeep, fontWeight = FontWeight.Bold)
            }
        }
    }
}

@Composable
private fun RuleCard(icon: String, text: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(8.dp))
            .background(SurfaceCard)
            .padding(10.dp),
        verticalAlignment = Alignment.Top,
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Text(icon, fontSize = 16.sp)
        Text(text, color = TextPrimary, fontSize = 12.sp, lineHeight = 16.sp)
    }
}
