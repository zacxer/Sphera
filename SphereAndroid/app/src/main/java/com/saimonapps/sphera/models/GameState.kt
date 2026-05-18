package com.saimonapps.sphera.models

data class GameState(
    val tubes: List<Tube> = emptyList(),
    val moves: Int = 0,
    val currentLevel: Int = 1,
    val selectedTubeIndex: Int? = null,
    val moveHistory: List<GameMove> = emptyList()
) {
    val isWon: Boolean get() = tubes.all { it.isEmpty || it.isComplete }
    val canUndo: Boolean get() = moveHistory.isNotEmpty()

    fun selectTube(index: Int): Pair<GameState, MoveResult> {
        if (index < 0 || index >= tubes.size) return Pair(this, MoveResult.INVALID)

        if (selectedTubeIndex == null) {
            val tube = tubes[index]
            if (tube.isEmpty) return Pair(this, MoveResult.INVALID)
            if (tube.isComplete) {
                val hasTall = tubes.any { it.type == TubeType.TALL }
                if (!hasTall) return Pair(this, MoveResult.INVALID)
            }
            if (tube.isTubeLocked) return Pair(this, MoveResult.INVALID)
            if (!tube.canRemoveTop()) return Pair(this, MoveResult.INVALID)
            return Pair(copy(selectedTubeIndex = index), MoveResult.SELECTED)
        }

        if (selectedTubeIndex == index) {
            return Pair(copy(selectedTubeIndex = null), MoveResult.DESELECTED)
        }

        return moveBall(selectedTubeIndex, index)
    }

    fun moveBall(sourceIndex: Int, destIndex: Int): Pair<GameState, MoveResult> {
        if (sourceIndex < 0 || sourceIndex >= tubes.size ||
            destIndex < 0 || destIndex >= tubes.size ||
            sourceIndex == destIndex) {
            return Pair(copy(selectedTubeIndex = null), MoveResult.INVALID)
        }

        if (!tubes[sourceIndex].canRemoveTop()) {
            return Pair(copy(selectedTubeIndex = null), MoveResult.INVALID)
        }

        val ball = tubes[sourceIndex].topBall
            ?: return Pair(copy(selectedTubeIndex = null), MoveResult.INVALID)

        var actualDestIndex = destIndex
        if (tubes[destIndex].isPortal) {
            val linkedIndex = findLinkedPortalIndex(destIndex)
            if (linkedIndex != null && tubes[linkedIndex].canReceiveBall(ball)) {
                actualDestIndex = linkedIndex
            }
        }

        if (!tubes[actualDestIndex].canReceiveBall(ball)) {
            return Pair(copy(selectedTubeIndex = null), MoveResult.INVALID)
        }

        val move = GameMove(
            sourceIndex = sourceIndex,
            destIndex = destIndex,
            ball = ball,
            actualDestIndex = if (actualDestIndex != destIndex) actualDestIndex else null
        )

        val newTubes = tubes.toMutableList()
        val (srcTube, _) = newTubes[sourceIndex].withTopRemoved()
        newTubes[sourceIndex] = srcTube
        newTubes[actualDestIndex] = newTubes[actualDestIndex].withBallAdded(ball)

        var newState = copy(
            tubes = newTubes,
            moves = moves + 1,
            selectedTubeIndex = null,
            moveHistory = moveHistory + move
        )

        newState = newState.processSpecialTubes()

        return if (newState.isWon) Pair(newState, MoveResult.WON)
        else Pair(newState, MoveResult.MOVED)
    }

    fun processSpecialTubes(): GameState {
        val newTubes = tubes.toMutableList()
        for (i in newTubes.indices) {
            when (newTubes[i].type) {
                TubeType.FROZEN -> {
                    newTubes[i] = newTubes[i].withFreezeDecremented()
                }
                TubeType.LOCKED -> {
                    if (newTubes[i].isTubeLocked) {
                        val hasCompleted = newTubes.indices.any { j -> j != i && newTubes[j].isComplete }
                        if (hasCompleted) newTubes[i] = newTubes[i].unlocked()
                    }
                }
                else -> {}
            }
        }
        return copy(tubes = newTubes)
    }

    fun findLinkedPortalIndex(tubeIndex: Int): Int? {
        val tube = tubes[tubeIndex]
        if (!tube.isPortal) return null
        if (tube.linkedPortalId != null) {
            return tubes.indexOfFirst { it.id == tube.linkedPortalId }.takeIf { it >= 0 }
        }
        val targetType = if (tube.type == TubeType.PORTAL_A) TubeType.PORTAL_B else TubeType.PORTAL_A
        return tubes.indices.firstOrNull { i ->
            i != tubeIndex && tubes[i].type == targetType && tubes[i].portalColor == tube.portalColor
        }
    }

    fun undoLastMove(): Pair<GameState, Boolean> {
        val lastMove = moveHistory.lastOrNull() ?: return Pair(this, false)
        val removeFrom = lastMove.actualDestIndex ?: lastMove.destIndex

        val newTubes = tubes.toMutableList()
        val (destTube, _) = newTubes[removeFrom].withTopRemoved()
        newTubes[removeFrom] = destTube
        newTubes[lastMove.sourceIndex] = newTubes[lastMove.sourceIndex].withBallAdded(lastMove.ball)

        return Pair(
            copy(
                tubes = newTubes,
                moves = maxOf(0, moves - 1),
                selectedTubeIndex = null,
                moveHistory = moveHistory.dropLast(1)
            ),
            true
        )
    }

    fun withTubes(newTubes: List<Tube>): GameState = copy(tubes = newTubes)
}
