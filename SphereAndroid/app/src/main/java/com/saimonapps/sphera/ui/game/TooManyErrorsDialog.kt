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
import com.saimonapps.sphera.services.L10n
import com.saimonapps.sphera.ui.theme.*

@Composable
fun TooManyErrorsDialog(
    errorCount: Int,
    maxErrors: Int,
    onRestart: () -> Unit,
    onDismiss: () -> Unit
) {
    Dialog(onDismissRequest = onDismiss) {
        Column(
            modifier = Modifier
                .clip(RoundedCornerShape(20.dp))
                .background(BgMid)
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text("😵", fontSize = 40.sp)
            Spacer(Modifier.height(8.dp))
            Text(L10n.tooManyErrors, fontWeight = FontWeight.Bold, fontSize = 22.sp, color = BallRed)
            Spacer(Modifier.height(6.dp))
            Text(
                L10n.youMadeErrors.format(errorCount),
                color = TextSecondary, fontSize = 13.sp, textAlign = TextAlign.Center
            )
            Text(
                L10n.dontGiveUp,
                color = TextSecondary, fontSize = 12.sp, textAlign = TextAlign.Center
            )
            Spacer(Modifier.height(16.dp))
            Button(
                onClick = onRestart,
                modifier = Modifier.fillMaxWidth(),
                colors = ButtonDefaults.buttonColors(containerColor = AccentGold)
            ) {
                Text(L10n.restart, color = BgDeep, fontWeight = FontWeight.Bold)
            }
            Spacer(Modifier.height(6.dp))
            TextButton(onClick = onDismiss, modifier = Modifier.fillMaxWidth()) {
                Text(L10n.cancel, color = TextSecondary)
            }
        }
    }
}
