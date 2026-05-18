package com.saimonapps.sphera.models

enum class ShapeType(val ordinal0: Int) {
    BALL(0), CUBE(1), PYRAMID(2), STAR(3), DIAMOND(4);

    companion object {
        fun fromOrdinal(v: Int) = entries.find { it.ordinal0 == v } ?: BALL
    }
}
