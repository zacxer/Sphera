package com.saimonapps.sphera.models

import java.util.UUID

data class Tube(
    val id: String = UUID.randomUUID().toString(),
    val balls: List<Ball> = emptyList(),
    val type: TubeType = TubeType.NORMAL,
    val freezeCountdown: Int? = null,
    val isLocked: Boolean? = null,
    val linkedPortalId: String? = null,
    val portalColor: PortalColor? = null
) {
    val capacity: Int get() = type.capacity
    val isEmpty: Boolean get() = balls.isEmpty()
    val isFull: Boolean get() = balls.size >= capacity
    val topBall: Ball? get() = balls.lastOrNull()
    val bottomBall: Ball? get() = balls.firstOrNull()

    val isComplete: Boolean get() {
        if (balls.size != capacity) return false
        val first = balls.firstOrNull() ?: return false
        return balls.all { it.isIdenticalTo(first) }
    }

    val consecutiveTopBallsCount: Int get() {
        val top = topBall ?: return 0
        var count = 0
        for (ball in balls.reversed()) {
            if (ball.isIdenticalTo(top)) count++ else break
        }
        return count
    }

    val isTopBallFrozen: Boolean get() =
        type == TubeType.FROZEN && (freezeCountdown ?: 0) > 0 && balls.isNotEmpty()

    val isTubeLocked: Boolean get() =
        type == TubeType.LOCKED && (isLocked ?: false)

    val isPortal: Boolean get() = type.isPortal

    fun canReceiveBall(ball: Ball): Boolean {
        if (isTubeLocked) return false
        if (isEmpty) return true
        if (isFull) return false
        val top = topBall ?: return true
        return ball.canStackWith(top)
    }

    fun canRemoveTop(): Boolean {
        if (isEmpty) return false
        if (isTubeLocked) return false
        if (isTopBallFrozen) return false
        return true
    }

    fun withBallAdded(ball: Ball): Tube =
        copy(balls = balls + ball)

    fun withTopRemoved(): Pair<Tube, Ball?> {
        if (isEmpty) return Pair(this, null)
        val removed = balls.last()
        return Pair(copy(balls = balls.dropLast(1)), removed)
    }

    fun withFreezeDecremented(): Tube {
        if (type != TubeType.FROZEN) return this
        val cd = freezeCountdown ?: return this
        return if (cd > 0) copy(freezeCountdown = cd - 1) else this
    }

    fun unlocked(): Tube = copy(isLocked = false)
}

enum class PortalColor(val key: String) {
    PURPLE("purple"), ORANGE("orange"), CYAN("cyan");

    companion object {
        fun fromKey(key: String) = entries.find { it.key == key } ?: PURPLE
    }
}
