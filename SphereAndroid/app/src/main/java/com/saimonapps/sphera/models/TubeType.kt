package com.saimonapps.sphera.models

import androidx.compose.ui.graphics.Color
import com.saimonapps.sphera.ui.theme.*

enum class TubeType(val key: String) {
    NORMAL("normal"),
    FROZEN("frozen"),
    TALL("tall"),
    LOCKED("locked"),
    PORTAL_A("portalA"),
    PORTAL_B("portalB");

    val capacity: Int get() = if (this == TALL) 6 else 4

    val isPortal: Boolean get() = this == PORTAL_A || this == PORTAL_B

    val accentColor: Color get() = when (this) {
        FROZEN -> TubeFrozenAccent
        TALL -> TubeTallAccent
        LOCKED -> TubeLockedAccent
        PORTAL_A, PORTAL_B -> TubePortalAccent
        else -> Color.Transparent
    }

    companion object {
        fun fromKey(key: String) = entries.find { it.key == key } ?: NORMAL
    }
}
