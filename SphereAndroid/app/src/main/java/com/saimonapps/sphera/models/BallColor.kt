package com.saimonapps.sphera.models

import androidx.compose.ui.graphics.Color
import com.saimonapps.sphera.ui.theme.*

enum class BallColor(val ordinal0: Int) {
    RED(0), BLUE(1), GREEN(2), YELLOW(3),
    PURPLE(4), ORANGE(5), PINK(6), CYAN(7);

    val color: Color get() = when (this) {
        RED -> BallRed; BLUE -> BallBlue; GREEN -> BallGreen; YELLOW -> BallYellow
        PURPLE -> BallPurple; ORANGE -> BallOrange; PINK -> BallPink; CYAN -> BallCyan
    }

    val highlightColor: Color get() = when (this) {
        RED -> BallRedH; BLUE -> BallBlueH; GREEN -> BallGreenH; YELLOW -> BallYellowH
        PURPLE -> BallPurpleH; ORANGE -> BallOrangeH; PINK -> BallPinkH; CYAN -> BallCyanH
    }

    val shadowColor: Color get() = when (this) {
        RED -> BallRedS; BLUE -> BallBlueS; GREEN -> BallGreenS; YELLOW -> BallYellowS
        PURPLE -> BallPurpleS; ORANGE -> BallOrangeS; PINK -> BallPinkS; CYAN -> BallCyanS
    }

    companion object {
        fun fromOrdinal(v: Int) = entries.find { it.ordinal0 == v } ?: RED
    }
}
