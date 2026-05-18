package com.saimonapps.sphera.navigation

import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.lifecycle.viewmodel.compose.viewModel
import com.saimonapps.sphera.ui.screen.*
import com.saimonapps.sphera.viewmodel.GameViewModel

private enum class Screen { SPLASH, MENU, GAME, SETTINGS }

@Composable
fun SphereNavigation(modifier: Modifier = Modifier) {
    val vm: GameViewModel = viewModel()
    var screen by remember { mutableStateOf(Screen.SPLASH) }

    when (screen) {
        Screen.SPLASH -> SplashScreen(onFinished = { screen = Screen.MENU })
        Screen.MENU -> MenuScreen(
            vm = vm,
            onPlay = { screen = Screen.GAME },
            onSettings = { screen = Screen.SETTINGS }
        )
        Screen.GAME -> GameScreen(
            vm = vm,
            onBackToMenu = { screen = Screen.MENU }
        )
        Screen.SETTINGS -> SettingsScreen(
            vm = vm,
            onDismiss = { screen = Screen.MENU }
        )
    }
}
