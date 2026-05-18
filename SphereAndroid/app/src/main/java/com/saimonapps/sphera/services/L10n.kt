package com.saimonapps.sphera.services

object L10n {
    var isItalian: Boolean = true

    private val it get() = isItalian

    val ballSort get() = "BALL SORT"
    val puzzle get() = "PUZZLE"
    val play get() = if (it) "GIOCA" else "PLAY"
    val level get() = if (it) "Livello" else "Level"
    val sortBallsByColor get() = if (it) "Ordina le palline per colore!" else "Sort the balls by color!"

    val easy get() = if (it) "Facile" else "Easy"
    val medium get() = if (it) "Medio" else "Medium"
    val hard get() = if (it) "Difficile" else "Hard"
    val easyDesc get() = if (it) "3-4 colori, ideale per iniziare" else "3-4 colors, ideal for beginners"
    val mediumDesc get() = if (it) "4-6 colori, sfida bilanciata" else "4-6 colors, balanced challenge"
    val hardDesc get() = if (it) "5-8 colori, per esperti" else "5-8 colors, for experts"
    val difficulty get() = if (it) "Difficoltà" else "Difficulty"

    val moves get() = if (it) "mosse" else "moves"
    val undo get() = if (it) "Annulla" else "Undo"
    val hint get() = if (it) "Suggerisci" else "Hint"
    val extraTube get() = if (it) "Tubo +1" else "Tube +1"

    val fantastic get() = if (it) "FANTASTICO!" else "FANTASTIC!"
    val levelCompleted get() = if (it) "Livello %d completato" else "Level %d completed"
    val time get() = if (it) "Tempo" else "Time"
    val movesLabel get() = if (it) "Mosse" else "Moves"
    val yourMoves get() = if (it) "Le tue mosse" else "Your moves"
    val minMoves get() = if (it) "Obiettivo" else "Target"
    val timeBonus get() = if (it) "Bonus Tempo" else "Time Bonus"
    val points get() = if (it) "punti" else "points"
    val totalScore get() = if (it) "Punteggio Totale" else "Total Score"
    val nextLevel get() = if (it) "Prossimo Livello" else "Next Level"

    val tooManyErrors get() = if (it) "Troppi Errori!" else "Too Many Errors!"
    val youMadeErrors get() = if (it) "Hai fatto %d mosse sbagliate" else "You made %d wrong moves"
    val dontGiveUp get() = if (it) "Non mollare! Riprova con calma" else "Don't give up! Try again calmly"
    val restart get() = if (it) "Ricomincia" else "Restart"

    val settings get() = if (it) "Impostazioni" else "Settings"
    val sounds get() = if (it) "Suoni" else "Sounds"
    val music get() = if (it) "Musica" else "Music"
    val vibration get() = if (it) "Vibrazione" else "Vibration"
    val resetAll get() = if (it) "Resetta Tutto" else "Reset All"
    val resetWarning get() = if (it) "Tutti i progressi e le statistiche verranno cancellati. Questa azione non può essere annullata." else "All progress and statistics will be deleted. This action cannot be undone."
    val version get() = if (it) "Versione" else "Version"
    val done get() = if (it) "Fatto" else "Done"
    val cancel get() = if (it) "Annulla" else "Cancel"
    val reset get() = if (it) "Resetta" else "Reset"
    val close get() = if (it) "Chiudi" else "Close"
    val language get() = if (it) "Lingua" else "Language"

    val statistics get() = if (it) "Statistiche" else "Statistics"
    val stars get() = if (it) "Stelle" else "Stars"
    val record get() = if (it) "Record" else "Record"
    val completed get() = if (it) "Completati" else "Completed"

    val powerUps get() = if (it) "Power-ups" else "Power-ups"
    val coins get() = if (it) "Monete" else "Coins"
    val buy get() = if (it) "Compra" else "Buy"
    val use get() = if (it) "Usa" else "Use"
    val notEnoughCoins get() = if (it) "Monete insufficienti!" else "Not enough coins!"

    val powerUpShuffle get() = if (it) "Mescola" else "Shuffle"
    val powerUpColorBomb get() = if (it) "Bomba Colore" else "Color Bomb"
    val powerUpUndoAll get() = if (it) "Ricomincia" else "Restart"
    val powerUpFreezeTimer get() = if (it) "Gelo" else "Freeze"
    val powerUpMagicWand get() = if (it) "Bacchetta" else "Magic Wand"
    val powerUpShuffleDesc get() = if (it) "Rimescola le palline nei tubi" else "Shuffle balls in tubes"
    val powerUpColorBombDesc get() = if (it) "Rimuovi tutte le palline di un colore" else "Remove all balls of one color"
    val powerUpUndoAllDesc get() = if (it) "Torna all'inizio del livello" else "Return to level start"
    val powerUpFreezeTimerDesc get() = if (it) "Ferma il timer per 30 secondi" else "Stop timer for 30 seconds"
    val powerUpMagicWandDesc get() = if (it) "Completa un tubo" else "Complete one tube"
    val selectColor get() = if (it) "Seleziona Colore" else "Select Color"
    val magicWandNoSpace get() = if (it) "Nessun Tubo Libero!" else "No Empty Tube!"

    val shapesTutorialTitle get() = if (it) "Nuove Forme!" else "New Shapes!"
    val shapesTutorialSubtitle get() = if (it) "Ora ci sono diverse forme oltre alle palline!" else "Now there are different shapes besides balls!"
    val shapesTutorialRule1 get() = if (it) "Puoi impilare pezzi con stesso COLORE o stessa FORMA" else "You can stack pieces with same COLOR or same SHAPE"
    val shapesTutorialRule2 get() = if (it) "Per completare un tubo servono 4 pezzi IDENTICI (stesso colore E forma)" else "To complete a tube you need 4 IDENTICAL pieces (same color AND shape)"
    val shapesTutorialGotIt get() = if (it) "Ho Capito!" else "Got It!"

    val testerMode get() = if (it) "MODALITÀ TESTER" else "TESTER MODE"
    val jumpToLevel get() = if (it) "Salta a Livello" else "Jump to Level"
    val reportBug get() = if (it) "Segnala Bug" else "Report Bug"
    val go get() = if (it) "VAI" else "GO"

    val watchAdForCoins get() = if (it) "Guarda pubblicità per 25 monete" else "Watch ad for 25 coins"
    val watchAd get() = if (it) "Guarda Ad" else "Watch Ad"
}
