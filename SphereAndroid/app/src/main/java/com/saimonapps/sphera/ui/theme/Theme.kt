package com.saimonapps.sphera.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable

private val DarkColorScheme = darkColorScheme(
    primary = AccentGold,
    secondary = AccentGoldAlt,
    background = BgDeep,
    surface = SurfaceCard,
    onPrimary = BgDeep,
    onSecondary = BgDeep,
    onBackground = TextPrimary,
    onSurface = TextPrimary,
    surfaceVariant = SurfaceElevated,
    onSurfaceVariant = TextSecondary,
)

@Composable
fun SphereTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = DarkColorScheme,
        typography = SphereTypography,
        content = content
    )
}
