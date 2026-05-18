package com.saimonapps.sphera.models

import java.util.UUID
import kotlin.math.max
import kotlin.math.min
import kotlin.random.Random

data class Level(
    val number: Int,
    val difficulty: Difficulty = Difficulty.MEDIUM
) {
    val ballsPerTube = 4
    val availableShapes: List<ShapeType> = determineAvailableShapes(number, difficulty)
    val numberOfColors: Int
    val numberOfEmptyTubes: Int
    val optimalMoves: Int

    init {
        when (difficulty) {
            Difficulty.EASY -> when {
                number <= 10 -> { numberOfColors = 3; numberOfEmptyTubes = 2 }
                else -> { numberOfColors = 4; numberOfEmptyTubes = 2 }
            }
            Difficulty.MEDIUM -> when {
                number <= 5 -> { numberOfColors = 3; numberOfEmptyTubes = 2 }
                number <= 15 -> { numberOfColors = 4; numberOfEmptyTubes = 2 }
                number <= 30 -> { numberOfColors = 5; numberOfEmptyTubes = 2 }
                number <= 50 -> { numberOfColors = 6; numberOfEmptyTubes = 2 }
                else -> { numberOfColors = 6; numberOfEmptyTubes = 2 }
            }
            Difficulty.HARD -> when {
                number <= 3 -> { numberOfColors = 4; numberOfEmptyTubes = 2 }
                number <= 10 -> { numberOfColors = 5; numberOfEmptyTubes = 2 }
                number <= 20 -> { numberOfColors = 6; numberOfEmptyTubes = 2 }
                else -> { numberOfColors = 7; numberOfEmptyTubes = 2 }
            }
        }

        val base = numberOfColors * 4
        val multiplier = when (difficulty) {
            Difficulty.EASY -> 0.9
            Difficulty.MEDIUM -> 1.0
            Difficulty.HARD -> 1.2
        }
        optimalMoves = max(10, (base * multiplier).toInt())
    }

    val totalTubes: Int get() = numberOfColors + numberOfEmptyTubes
    val hasMultipleShapes: Boolean get() = availableShapes.size > 1

    val isFirstShapeIntroduction: Boolean get() {
        val prev = determineAvailableShapes(number - 1, difficulty)
        return availableShapes.size > prev.size
    }

    fun generateTubes(): List<Tube> {
        val tubeTypes = determineTubeTypes()
        val shapesForTubes = distributeShapesToTubes()
        val tubes = mutableListOf<Tube>()
        var portalAId: String? = null
        var portalBId: String? = null

        for (i in tubeTypes.indices) {
            val tubeType = tubeTypes[i]
            val isEmpty = i >= numberOfColors

            if (isEmpty) {
                tubes.add(Tube(type = tubeType))
            } else {
                val color = BallColor.fromOrdinal(i)
                val shape = shapesForTubes[i]
                val cap = tubeType.capacity
                val ballList = List(cap) { Ball(ballColor = color, shape = shape) }
                val tube = Tube(
                    balls = ballList,
                    type = tubeType,
                    freezeCountdown = if (tubeType == TubeType.FROZEN) 3 else null,
                    isLocked = if (tubeType == TubeType.LOCKED) true else null
                )
                when (tubeType) {
                    TubeType.PORTAL_A -> portalAId = tube.id
                    TubeType.PORTAL_B -> portalBId = tube.id
                    else -> {}
                }
                tubes.add(tube)
            }
        }

        if (portalAId != null && portalBId != null) {
            val aIdx = tubes.indexOfFirst { it.id == portalAId }
            val bIdx = tubes.indexOfFirst { it.id == portalBId }
            if (aIdx >= 0 && bIdx >= 0) {
                tubes[aIdx] = tubes[aIdx].copy(linkedPortalId = portalBId)
                tubes[bIdx] = tubes[bIdx].copy(linkedPortalId = portalAId)
            }
        }

        val shuffled = reverseShuffleTubes(tubes, calculateShuffleMoves())
        return shuffled
    }

    private fun calculateShuffleMoves(): Int {
        val base = when (difficulty) {
            Difficulty.EASY -> 15 + (number * 2)
            Difficulty.MEDIUM -> 25 + (number * 3)
            Difficulty.HARD -> 40 + (number * 4)
        }
        return min(base, 200)
    }

    private fun reverseShuffleTubes(initial: MutableList<Tube>, moves: Int): List<Tube> {
        val tubes = initial.toMutableList()
        var completed = 0
        var attempts = 0
        val maxAttempts = moves * 10

        while (completed < moves && attempts < maxAttempts) {
            attempts++
            val validSources = tubes.indices.filter { !tubes[it].isEmpty }
            if (validSources.isEmpty()) break
            val src = validSources.random()
            if (tubes[src].topBall == null) continue
            val validDests = tubes.indices.filter { it != src && !tubes[it].isFull }
            if (validDests.isEmpty()) continue
            val dst = validDests.random()
            if (tubes[src].balls.isNotEmpty()) {
                val ball = tubes[src].balls.last()
                tubes[src] = tubes[src].copy(balls = tubes[src].balls.dropLast(1))
                tubes[dst] = tubes[dst].copy(balls = tubes[dst].balls + ball)
                completed++
            }
        }

        var extras = 0
        while (tubes.any { it.isComplete && !it.isEmpty } && extras < 50) {
            extras++
            for (i in tubes.indices) {
                if (tubes[i].isComplete && !tubes[i].isEmpty) {
                    for (j in tubes.indices) {
                        if (i != j && !tubes[j].isFull && tubes[j].type != TubeType.LOCKED) {
                            val ball = tubes[i].balls.last()
                            tubes[i] = tubes[i].copy(balls = tubes[i].balls.dropLast(1))
                            tubes[j] = tubes[j].copy(balls = tubes[j].balls + ball)
                            break
                        }
                    }
                }
            }
        }

        return tubes
    }

    private fun distributeShapesToTubes(): List<ShapeType> {
        if (availableShapes.size == 1) return List(numberOfColors) { ShapeType.BALL }
        val pool = availableShapes.toMutableList()
        while (pool.size < numberOfColors) pool.add(availableShapes.random())
        return pool.shuffled().take(numberOfColors)
    }

    private fun determineTubeTypes(): List<TubeType> {
        val introLevels = when (difficulty) {
            Difficulty.EASY -> 20; Difficulty.MEDIUM -> 15; Difficulty.HARD -> 10
        }
        if (number <= introLevels) {
            val types = MutableList(numberOfColors) { TubeType.NORMAL }
            repeat(numberOfEmptyTubes) { types.add(TubeType.NORMAL) }
            return types
        }
        val adv = number - introLevels
        val types = when (difficulty) {
            Difficulty.EASY -> generateEasy(adv)
            Difficulty.MEDIUM -> generateMedium(adv)
            Difficulty.HARD -> generateHard(adv)
        }
        return randomizeTubePositions(types)
    }

    private fun generateEasy(adv: Int): MutableList<TubeType> {
        val t = MutableList(numberOfColors) { TubeType.NORMAL }
        if (adv > 0 && numberOfColors >= 3) t[0] = TubeType.FROZEN
        repeat(numberOfEmptyTubes) { t.add(TubeType.NORMAL) }
        return t
    }

    private fun generateMedium(adv: Int): MutableList<TubeType> {
        val t = MutableList(numberOfColors) { TubeType.NORMAL }
        if (numberOfColors >= 3) {
            if (adv >= 1) t[0] = TubeType.FROZEN
            if (adv >= 6 && numberOfColors >= 4) t[1] = TubeType.TALL
            if (adv >= 11 && numberOfColors >= 5) t[2] = TubeType.LOCKED
            if (adv >= 16 && numberOfColors >= 6) t[3] = TubeType.FROZEN
        }
        repeat(numberOfEmptyTubes) { t.add(TubeType.NORMAL) }
        return t
    }

    private fun generateHard(adv: Int): MutableList<TubeType> {
        val t = MutableList(numberOfColors) { TubeType.NORMAL }
        if (numberOfColors >= 4) {
            if (adv >= 1) { t[0] = TubeType.FROZEN; t[1] = TubeType.TALL }
            if (adv >= 6 && numberOfColors >= 5) t[2] = TubeType.LOCKED
            if (adv >= 11 && numberOfColors >= 6) { t[3] = TubeType.PORTAL_A; t[4] = TubeType.PORTAL_B }
            if (adv >= 16 && numberOfColors >= 7) t[5] = TubeType.FROZEN
        }
        repeat(numberOfEmptyTubes) { t.add(TubeType.NORMAL) }
        return t
    }

    private fun randomizeTubePositions(types: MutableList<TubeType>): MutableList<TubeType> {
        val filled = types.take(numberOfColors).shuffled()
        val empty = types.takeLast(numberOfEmptyTubes)
        return (filled + empty).toMutableList()
    }

    companion object {
        fun determineAvailableShapes(level: Int, difficulty: Difficulty): List<ShapeType> {
            val offset = when (difficulty) {
                Difficulty.EASY -> 0; Difficulty.MEDIUM -> -5; Difficulty.HARD -> -10
            }
            val eff = level + offset
            return when {
                eff <= 15 -> listOf(ShapeType.BALL)
                eff <= 25 -> listOf(ShapeType.BALL, ShapeType.CUBE)
                eff <= 35 -> listOf(ShapeType.BALL, ShapeType.CUBE, ShapeType.PYRAMID)
                eff <= 45 -> listOf(ShapeType.BALL, ShapeType.CUBE, ShapeType.PYRAMID, ShapeType.STAR)
                else -> ShapeType.entries.toList()
            }
        }
    }
}
