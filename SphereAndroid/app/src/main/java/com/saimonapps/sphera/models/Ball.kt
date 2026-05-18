package com.saimonapps.sphera.models

import java.util.UUID

data class Ball(
    val id: String = UUID.randomUUID().toString(),
    val ballColor: BallColor,
    val shape: ShapeType = ShapeType.BALL
) {
    fun canStackWith(other: Ball): Boolean =
        ballColor == other.ballColor || shape == other.shape

    fun isIdenticalTo(other: Ball): Boolean =
        ballColor == other.ballColor && shape == other.shape
}
