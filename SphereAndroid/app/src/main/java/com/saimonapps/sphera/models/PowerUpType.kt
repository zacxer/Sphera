package com.saimonapps.sphera.models

import androidx.compose.ui.graphics.Color
import com.saimonapps.sphera.ui.theme.*

enum class PowerUpType(val key: String, val cost: Int) {
    UNDO_ALL("undoAll", 30),
    SHUFFLE("shuffle", 50),
    FREEZE_TIMER("freezeTimer", 75),
    MAGIC_WAND("magicWand", 120),
    COLOR_BOMB("colorBomb", 150);

    val color: Color get() = when (this) {
        SHUFFLE -> PowerUpShuffleColor
        COLOR_BOMB -> PowerUpBombColor
        UNDO_ALL -> PowerUpUndoAllColor
        FREEZE_TIMER -> PowerUpFreezeColor
        MAGIC_WAND -> PowerUpWandColor
    }

    companion object {
        fun fromKey(key: String) = entries.find { it.key == key } ?: UNDO_ALL
    }
}
