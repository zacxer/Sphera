package com.saimonapps.sphera.models

data class GameMove(
    val sourceIndex: Int,
    val destIndex: Int,
    val ball: Ball,
    val actualDestIndex: Int? = null
)
