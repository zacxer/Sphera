package com.saimonapps.sphera.ui.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.saimonapps.sphera.BuildConfig
import com.saimonapps.sphera.services.L10n
import com.saimonapps.sphera.ui.theme.*
import com.saimonapps.sphera.viewmodel.GameViewModel

@Composable
fun SettingsScreen(vm: GameViewModel, onDismiss: () -> Unit) {
    val soundEnabled by vm.soundEnabled.collectAsStateWithLifecycle()
    val musicEnabled by vm.musicEnabled.collectAsStateWithLifecycle()
    val vibrationEnabled by vm.vibrationEnabled.collectAsStateWithLifecycle()
    val language by vm.languageFlow.collectAsStateWithLifecycle()
    var showResetConfirm by remember { mutableStateOf(false) }

    AnimatedBackground {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(24.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(L10n.settings, fontWeight = FontWeight.Bold, fontSize = 24.sp, color = TextPrimary)
                TextButton(onClick = onDismiss) { Text(L10n.done, color = AccentGold) }
            }

            Spacer(Modifier.height(16.dp))

            SettingsSection(title = "🔊 ${L10n.sounds}") {
                ToggleRow(L10n.sounds, soundEnabled) { vm.setSoundEnabled(it) }
                ToggleRow(L10n.music, musicEnabled) { vm.setMusicEnabled(it) }
                ToggleRow(L10n.vibration, vibrationEnabled) { vm.setVibrationEnabled(it) }
            }

            Spacer(Modifier.height(12.dp))

            SettingsSection(title = "🌐 ${L10n.language}") {
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    listOf("IT" to "🇮🇹 Italiano", "EN" to "🇬🇧 English").forEach { (code, label) ->
                        FilterChip(
                            selected = language == code,
                            onClick = { vm.setLanguage(code) },
                            label = { Text(label, fontSize = 12.sp) },
                            colors = FilterChipDefaults.filterChipColors(
                                selectedContainerColor = AccentGold,
                                selectedLabelColor = BgDeep
                            )
                        )
                    }
                }
            }

            Spacer(Modifier.height(12.dp))

            SettingsSection(title = "🗑 ${L10n.resetAll}") {
                Button(
                    onClick = { showResetConfirm = true },
                    colors = ButtonDefaults.buttonColors(containerColor = BallRed.copy(alpha = 0.8f)),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text(L10n.resetAll, color = TextPrimary)
                }
                Text(L10n.resetWarning, color = TextSecondary, fontSize = 11.sp, lineHeight = 15.sp)
            }

            Spacer(Modifier.height(12.dp))

            SettingsSection(title = "ℹ ${L10n.version}") {
                Text("Sphera v${BuildConfig.VERSION_NAME}", color = TextSecondary, fontSize = 13.sp)
                Text("com.saimonapps.sphera", color = TextSecondary, fontSize = 11.sp)
            }
        }
    }

    if (showResetConfirm) {
        AlertDialog(
            onDismissRequest = { showResetConfirm = false },
            containerColor = BgMid,
            title = { Text("${L10n.resetAll}?", color = TextPrimary) },
            text = { Text(L10n.resetWarning, color = TextSecondary) },
            confirmButton = {
                TextButton(onClick = { showResetConfirm = false; vm.resetAllProgress() }) {
                    Text(L10n.reset, color = BallRed)
                }
            },
            dismissButton = {
                TextButton(onClick = { showResetConfirm = false }) {
                    Text(L10n.cancel, color = TextSecondary)
                }
            }
        )
    }
}

@Composable
private fun SettingsSection(title: String, content: @Composable ColumnScope.() -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(SurfaceCard)
            .padding(14.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Text(title, color = TextSecondary, fontSize = 12.sp, fontWeight = FontWeight.SemiBold)
        content()
    }
}

@Composable
private fun ToggleRow(label: String, checked: Boolean, onToggle: (Boolean) -> Unit) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(label, color = TextPrimary, fontSize = 14.sp)
        Switch(
            checked = checked, onCheckedChange = onToggle,
            colors = SwitchDefaults.colors(checkedThumbColor = AccentGold, checkedTrackColor = AccentGold.copy(alpha = 0.4f))
        )
    }
}
