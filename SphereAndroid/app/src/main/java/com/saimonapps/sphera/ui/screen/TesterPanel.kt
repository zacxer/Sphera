package com.saimonapps.sphera.ui.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import com.saimonapps.sphera.services.L10n
import com.saimonapps.sphera.ui.theme.*
import com.saimonapps.sphera.viewmodel.GameViewModel

@Composable
fun TesterPanel(vm: GameViewModel, onDismiss: () -> Unit) {
    var levelInput by remember { mutableStateOf("") }

    Dialog(onDismissRequest = onDismiss) {
        Column(
            modifier = Modifier
                .clip(RoundedCornerShape(20.dp))
                .background(BgMid)
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(L10n.testerMode, fontWeight = FontWeight.Bold, fontSize = 16.sp, color = BallRed)
            Spacer(Modifier.height(12.dp))

            OutlinedTextField(
                value = levelInput,
                onValueChange = { levelInput = it.filter { c -> c.isDigit() } },
                label = { Text(L10n.jumpToLevel, color = TextSecondary) },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                singleLine = true,
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = AccentGold, unfocusedBorderColor = SurfaceElevated,
                    focusedTextColor = TextPrimary, unfocusedTextColor = TextPrimary
                ),
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(Modifier.height(8.dp))

            // Quick jump buttons
            Row(horizontalArrangement = Arrangement.spacedBy(6.dp), modifier = Modifier.fillMaxWidth()) {
                listOf(1, 10, 20, 50, 100).forEach { lvl ->
                    FilterChip(
                        selected = false,
                        onClick = { vm.jumpToLevel(lvl); onDismiss() },
                        label = { Text("$lvl", fontSize = 11.sp) },
                        modifier = Modifier.weight(1f)
                    )
                }
            }

            Spacer(Modifier.height(8.dp))

            Button(
                onClick = {
                    val lvl = levelInput.toIntOrNull() ?: return@Button
                    vm.jumpToLevel(lvl); onDismiss()
                },
                enabled = levelInput.isNotEmpty(),
                modifier = Modifier.fillMaxWidth(),
                colors = ButtonDefaults.buttonColors(containerColor = AccentGold)
            ) {
                Text(L10n.go, color = BgDeep, fontWeight = FontWeight.Bold)
            }

            Spacer(Modifier.height(4.dp))

            TextButton(onClick = onDismiss, modifier = Modifier.fillMaxWidth()) {
                Text(L10n.close, color = TextSecondary)
            }
        }
    }
}
