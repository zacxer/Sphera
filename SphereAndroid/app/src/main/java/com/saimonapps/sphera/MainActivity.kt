package com.saimonapps.sphera

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.ui.Modifier
import com.saimonapps.sphera.navigation.SphereNavigation
import com.saimonapps.sphera.ui.theme.SphereTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            SphereTheme {
                SphereNavigation(modifier = Modifier.fillMaxSize())
            }
        }
    }
}
