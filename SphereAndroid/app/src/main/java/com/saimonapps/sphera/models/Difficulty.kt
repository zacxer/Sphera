package com.saimonapps.sphera.models

enum class Difficulty(val key: String) {
    EASY("easy"),
    MEDIUM("medium"),
    HARD("hard");

    companion object {
        fun fromKey(key: String) = entries.find { it.key == key } ?: MEDIUM
    }
}
