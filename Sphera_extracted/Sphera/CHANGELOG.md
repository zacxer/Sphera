# Changelog - Sphera Puzzle

Tutte le modifiche importanti al progetto saranno documentate in questo file.

Il formato si basa su [Keep a Changelog](https://keepachangelog.com/it/1.0.0/).

---

## [1.0.5] - 2026-01-09

### Modificato
- **Nuova icona app**: Icona completamente rinnovata
- **Nuovo nome display**: "Sphera Puzzle" (prima "Sphera")

### Build
- MARKETING_VERSION: 1.0.5
- CURRENT_PROJECT_VERSION: 5

---

## [1.0.4] - 2026-01-07

### Aggiunto
- **Effetto completamento tubo**:
  - Animazione celebrativa quando si completa un tubo
  - Checkmark verde con effetto bounce
  - 6 stelle gialle che esplodono dal centro
  - Anello di luce verde che si espande
  - Suono di completamento (SystemSoundID 1114)
  - Vibrazione haptic success
  - L'effetto appare solo sul tubo appena completato

### Riattivato
- **ADS riattivati per pubblicazione**:
  - `ContentView.swift`: BannerAdView riattivato
  - `PowerUpViews.swift`: Bottone AD play.circle.fill riattivato
  - `PowerUpViews.swift`: Bottone "Guarda AD +25" nello shop riattivato

### Migliorato
- **Sezione Settings professionale**:
  - Rimosso "Made with 💜"
  - Aggiunto link "Support" → saimonapps.github.io
  - Aggiunto link "Privacy Policy" → saimonapps.github.io
  - Footer copyright: "© 2026 S@imon Apps. All rights reserved."
  - Icone colorate per ogni voce Info

### Compatibilità
- **Supporto iPhone e iPad**:
  - TARGETED_DEVICE_FAMILY = "1,2" (iPhone + iPad)
  - Layout SwiftUI adattivo per tutti i dispositivi

### Build
- MARKETING_VERSION: 1.0.4
- CURRENT_PROJECT_VERSION: 4

### File Modificati
- `TubeView.swift`: Aggiunto `TubeCompletionAnimatedEffect`
- `GameViewModel.swift`: Aggiunto rilevamento completamento tubo (`justCompletedTubeIndex`)
- `GameView.swift`: Passaggio parametro `showCompletionEffect` a TubeView
- `AudioManager.swift`: Aggiunto `playTubeCompleteSound()`
- `ContentView.swift`: Riattivato BannerAdView
- `PowerUpViews.swift`: Riattivati bottoni AD
- `MenuView.swift`: Sezione Settings con link Support/Privacy e copyright

---

## [1.0.3] - 2026-01-06

### Migliorato
- **Spacing tubi più compatto**:
  - Scala ridotta ulteriormente (0.62x per 10 tubi, 0.65x per 9 tubi)
  - Spacing negativo aumentato (-14px per 10 tubi)
  - I tubi non escono più dallo schermo

- **Magic Wand ora fa scegliere il colore**:
  - Prima: completava un colore a caso
  - Ora: mostra selettore colori come Color Bomb
  - Il giocatore sceglie quale colore vuole completare
  - UI con icona bacchetta e sparkles sui colori

### Build
- MARKETING_VERSION: 1.0.3
- CURRENT_PROJECT_VERSION: 3

---

## [1.0.2] - 2026-01-06

### Corretto
- **Tubi frozen/locked già completi**:
  - I tubi speciali ora vengono mescolati correttamente durante la generazione
  - Nessun tubo è mai già completo all'inizio del livello
  - Le palline possono essere spostate da/verso tutti i tubi durante lo shuffle

- **Rimosso tipo tubo "Rotating"**:
  - Eliminato completamente `TubeType.rotating` (frecce arancioni)
  - Rimosso `RotatingTubeOverlay` e tutto il codice associato
  - Era codice residuo non più in uso

### Migliorato
- **Limite massimo tubi**:
  - Max 9 tubi + 1 extra = 10 totale
  - Hard mode: max 7 colori (invece di 8)
  - Previene overflow su schermo

- **Spacing dinamico migliorato**:
  - Scala ridotta a 0.72x per 10 tubi
  - Max 5 colonne per riga
  - Spacing negativo aumentato (-8px) per molti tubi
  - I tubi non escono più dallo schermo

### Aggiunto
- **Selettore livelli per Tester**:
  - Nuovo in Impostazioni → TESTER MODE → "Salta a Livello"
  - Griglia salto rapido: 1, 5, 10, 15, 20, 25, 30, 40, 50
  - Slider 1-100 per livello personalizzato
  - Solo visibile in Debug/TestFlight

### Build
- MARKETING_VERSION: 1.0.2
- CURRENT_PROJECT_VERSION: 2

---

## [1.1.7] - 2026-01-03

### Migliorato
- **Layout tubi adattivo**:
  - Spacing e scala dinamici in base al numero di colonne
  - 4 colonne: spacing 2px, scala 88%
  - 5 colonne: spacing -4px, scala 75%
  - 6 colonne: spacing -8px, scala 68%
  - Tubi non escono piu' dallo schermo nei livelli difficili

- **Bottoni Undo/Hint con Rewarded Ads**:
  - Quando esauriti gli undo -> mostra "AD" e guardando la pubblicita' si ottengono +3 undo
  - Quando esauriti gli hint -> mostra "AD" e guardando la pubblicita' si ottengono +2 hint
  - Bottoni rimangono attivi anche a 0 (cambiano comportamento)

- **Posizione barra azioni corretta**:
  - Bottoni (Annulla, Suggerisci, Tubo+1) ora posizionati appena sopra il banner
  - Spacer aggiunto per layout stabile
  - Altezza fissa 90px per la barra

### Corretto
- AdManager: rewarded sempre pronto per testing (isRewardedReady = true)
- Icona Tubo+1 cambiata a plus.circle.fill

---

## [1.1.6] - 2026-01-03

### Migliorato
- **Suono selezione tubo aggiunto**:
  - Nuovo suono tock (1104) quando si seleziona un tubo
  - Feedback audio immediato per ogni interazione

- **Volume suono spostamento QUINTUPLICATO**:
  - 5 riproduzioni rapide (20ms intervallo) per volume massimo
  - Suono 1306 (keyboard click forte) per effetto piu' potente

- **Vibrazione deselection aggiunta**:
  - Vibrazione leggera quando si deseleziona un tubo toccandolo di nuovo
  - Feedback aptico completo per tutte le interazioni

### Corretto
- **Fix freeze dopo completamento livello**:
  - Cambiato da DispatchQueue.main.asyncAfter a Task con @MainActor
  - Risolto problema di riferimenti weak che causavano mancata esecuzione
  - Animazione completamento ora sempre affidabile

---

## [1.1.5] - 2026-01-03

### Migliorato
- **Suono spostamento palla TRIPLICATO**:
  - 3 riproduzioni rapide (30ms intervallo) per volume piu' alto
  - Suono 1104 (tock) ripetuto per effetto piu' forte
  - Pronto per effetti sonori personalizzati futuri

- **Tubi piu' alti nel gioco**:
  - Altezza tubo: 215px (prima 195px)
  - Proporzioni migliori con le palline

---

## [1.1.4] - 2026-01-03

### Migliorato
- **Palline GLASS nel menu**:
  - Effetto vetro piu' pronunciato con trasparenze
  - Riflessi multipli (3 livelli)
  - Ombra sotto le palline
  - Overlay gradiente trasparente
  - Bordo luminoso glass

- **Tubi e palline piu' compatti**:
  - Tubo: 58x195px (prima 70x240px)
  - Pallina: 44px (prima 52px)
  - Piu' spazio per i pulsanti azioni

- **Pulsanti azioni visibili sopra banner**:
  - Padding bottom aumentato a 70-80px
  - Nessuna sovrapposizione con banner

---

## [1.1.3] - 2026-01-03

### Migliorato
- **Banner sempre visibile**:
  - Banner pubblicitario ora presente anche nella schermata principale
  - Padding aggiunto a MenuView per non coprire il footer

- **Sistema Haptic migliorato**:
  - Generator persistenti per performance migliori
  - `.prepare()` chiamato prima di ogni vibrazione
  - Vibrazione selezione: medium (prima light)
  - Vibrazione spostamento: medium (prima light)
  - Vibrazione errore: heavy (prima medium)

- **Suono spostamento palla piu' forte**:
  - Cambiato da 1104 (tock) a 1306 (keyboard click)
  - Pronto per effetti sonori personalizzati

---

## [1.1.2] - 2026-01-03

### Migliorato
- **MenuView - Tubi 3D nel Menu**:
  - Tubi con effetto vetro lucente identico al gioco
  - Palline 3D con riflessi, ombre e glow colorato
  - `MenuBallView` dedicata per palline nel menu
  - Animazione fluida all'apparizione
  - Tubi ridimensionati (44x140px) per layout piu' compatto

- **Layout Ottimizzato**:
  - MenuView ora rispetta la safe area in alto (orologio/notch)
  - Schermata di gioco ora rispetta la safe area
  - Usato GeometryReader per adattare padding dinamicamente
  - Animazione selezione tubo non sposta piu' la schermata
  - Frame fisso per tubi evita shift del layout
  - Pulsanti azioni (Annulla, Suggerisci, Tubo+1) ora sopra il banner

### Corretto
- Rimossi 3 warning in GameViewModel.swift (variabili non utilizzate)
- Banner pubblicitario non copre piu' i pulsanti azioni

---

## [1.1.1] - 2026-01-03

### Aggiunto
- **Animazione Spostamento Pallina**:
  - La pallina ora "vola" con traiettoria ad arco (curva Bezier quadratica)
  - Animazione fluida di 0.35 secondi
  - La pallina scompare dal tubo sorgente durante l'animazione
  - `FlyingBallView` per gestire la pallina in volo
  - Tracciamento posizioni tubi con GeometryReader

### Modificato
- **Tubo Extra ora richiede Rewarded Ad**:
  - Icona cambiata da "+" a "play" (video)
  - Badge "AD" sul pulsante
  - Chiama `AdManager.shared.showRewardedAd()` prima di aggiungere il tubo
  - Il tubo viene aggiunto solo dopo aver visto l'ad

- **GameViewModel.swift**:
  - Nuova logica `startMoveAnimation()` e `completeMoveAnimation()`
  - Separazione tra verifica mossa e esecuzione per supportare animazione
  - Reset animazione con `resetAnimation()`

- **TubeView.swift**:
  - Nuovo parametro `isAnimatingSource` per nascondere pallina in cima durante animazione
  - Spazio vuoto al posto della pallina animata

- **GameView.swift**:
  - `TubesContainerView` ora traccia posizioni tubi con `tubePositions`
  - Overlay `FlyingBallView` per mostrare pallina in volo
  - Pulsante Tubo Extra modificato per rewarded ad

---

## [1.1.0] - 2026-01-03

### Aggiunto
- **Sistema Undo**: 5 annullamenti gratuiti per livello
  - Pulsante "Annulla" con badge contatore
  - History delle mosse per ripristino
  - Possibilita' di ottenere undo extra tramite rewarded ads (struttura pronta)

- **Sistema Hint**: 2 suggerimenti gratuiti per livello
  - Pulsante "Suggerisci" con badge contatore
  - Highlight animato del tubo sorgente (giallo pulsante)
  - Highlight animato del tubo destinazione (verde pulsante)
  - Freccia indicatore sulla pallina da spostare
  - Auto-nascondimento dopo 3 secondi

- **Rate App Popup**: Richiesta recensione App Store
  - Si attiva dopo 5, 15, 30, 50, 75, 100 livelli completati
  - Rispetta il limite di 30 giorni tra le richieste
  - Usa SKStoreReviewController nativo

- **Struttura AdMob** (placeholder pronto per integrazione):
  - `AdManager.swift`: Gestione centralizzata ads
  - `BannerAdView.swift`: Vista banner in basso
  - ID di test predefiniti per sviluppo
  - Supporto per Banner, Interstitial e Rewarded Ads
  - Interstitial ogni 3 livelli (configurabile)
  - Rewarded per undo/hint extra

### Modificato
- **GameView.swift**:
  - Nuova barra azioni in basso (Undo, Hint, Tubo Extra)
  - Pulsanti compatti con badge
  - Passaggio parametri hint a TubesContainerView

- **TubeView.swift**:
  - Supporto per `isHintSource` e `isHintDest`
  - Animazione pulsante per hint
  - Glow colorato differenziato (giallo sorgente, verde destinazione)

- **GameViewModel.swift**:
  - Aggiunto sistema Undo completo
  - Aggiunto sistema Hint con algoritmo di ricerca mossa migliore
  - Integrazione RateAppManager
  - Timer per auto-nascondimento hint

- **GameState.swift**:
  - Aggiunta struct `GameMove` per history
  - Aggiunto array `moveHistory`
  - Funzione `undoLastMove()`

- **ContentView.swift**:
  - Aggiunto `BannerAdView` in basso durante il gioco

### Nuovi File
- `Managers/RateAppManager.swift`
- `Ads/AdManager.swift`
- `Ads/BannerAdView.swift`

---

## [1.0.0] - 2026-01-02

### Aggiunto
- **Struttura base del gioco**:
  - Modelli: Ball, Tube, GameState, Level
  - ViewModel: GameViewModel
  - Views: MenuView, GameView, TubeView, ContentView

- **Grafica 3D**:
  - Palline con effetto vetro/sfera lucida
  - Riflessi multipli e ombre
  - Tubi con effetto vetro trasparente
  - Glow colorati per selezione e completamento

- **Sistema di livelli**:
  - Generazione procedurale basata sulla difficolta'
  - 3 difficolta': Facile (3-4 colori), Medio (4-6), Difficile (5-8)
  - Progressione salvata separatamente per difficolta'

- **Sistema punteggio**:
  - Calcolo punteggio basato su mosse e livello
  - Sistema 3 stelle (ratio mosse/ottimali)
  - High score persistente
  - Statistiche: partite completate, stelle totali

- **Interfaccia utente**:
  - Menu principale con logo animato
  - Selettore difficolta' con descrizioni
  - Pannello statistiche
  - Pannello impostazioni (suoni, vibrazioni, reset)
  - Header di gioco con livello e mosse
  - Overlay vittoria con animazioni e confetti

- **Feedback**:
  - Suoni di sistema per mosse, errori, vittoria
  - Vibrazione aptica (light, medium, success)
  - Toggle per suoni e vibrazioni

- **Background animato**:
  - Gradiente dinamico
  - Particelle/stelle animate
  - Glow colorati di sfondo

### File Principali
- `Models/Ball.swift` - Modello pallina con 8 colori
- `Models/Tube.swift` - Modello tubo con capacita' 4
- `Models/GameState.swift` - Stato di gioco
- `Models/Level.swift` - Generatore livelli
- `Models/SettingsManager.swift` - Gestione impostazioni
- `ViewModels/GameViewModel.swift` - Logica di gioco
- `Views/MenuView.swift` - Menu principale
- `Views/GameView.swift` - Schermata di gioco
- `Views/TubeView.swift` - Vista tubo e palline
- `Views/ColorExtensions.swift` - Estensioni colori

---

## Note per lo Sviluppo

### Completati
- [x] Animazione spostamento pallina (curva Bezier) - v1.1.1
- [x] Sistema Undo (5 per livello) - v1.1.0
- [x] Sistema Hint (2 per livello) - v1.1.0
- [x] Rate App Popup - v1.1.0
- [x] Struttura AdMob (placeholder) - v1.1.0
- [x] Tubo Extra con Rewarded Ad - v1.1.1
- [x] Banner pubblicitario in basso - v1.1.0

### Prossimi Passi
- [ ] Integrazione effettiva Google Mobile Ads SDK
- [ ] Effetti sonori personalizzati
- [ ] Musica di sottofondo
- [ ] Localizzazione multilingua
- [ ] Game Center achievements
- [ ] Condivisione punteggio social
- [ ] Modalita' sfida giornaliera

### Configurazione AdMob
Per attivare AdMob:
1. Aggiungi SDK: `https://github.com/googleads/swift-package-manager-google-mobile-ads`
2. Configura Info.plist con GADApplicationIdentifier
3. Aggiungi SKAdNetwork IDs per AdMob
4. Sostituisci ID test con ID reali in `AdManager.swift`

### Testing
- Usare sempre ID di test durante sviluppo
- Verificare funzionamento su dispositivi reali per AdMob
- Testare su diverse dimensioni schermo (iPhone SE -> iPhone 15 Pro Max)
- Testare animazioni su dispositivi meno potenti

### Struttura Progetto Attuale
```
BallSortPuzzle/
├── Models/
│   ├── Ball.swift
│   ├── Tube.swift
│   ├── GameState.swift
│   ├── Level.swift
│   └── SettingsManager.swift
├── ViewModels/
│   └── GameViewModel.swift
├── Views/
│   ├── ContentView.swift
│   ├── MenuView.swift
│   ├── GameView.swift
│   ├── TubeView.swift
│   └── ColorExtensions.swift
├── Managers/
│   └── RateAppManager.swift
├── Ads/
│   ├── AdManager.swift
│   └── BannerAdView.swift
└── CHANGELOG.md
```

---

*Ultimo aggiornamento: 2026-01-09 (v1.0.5)*
