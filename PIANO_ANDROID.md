# Sphera Android — Piano di Conversione iOS → Android

> **Obiettivo:** Porting 1:1 del Ball Sort Puzzle iOS di Simone Gaetani.
> **Stack:** Kotlin · Jetpack Compose · ViewModel/StateFlow · DataStore · AdMob · MediaPlayer
> **Percorso:** `Q:\Codici\WIP\GoogleAppStore\sphera\SphereAndroid\`
> **Package:** `com.saimonapps.sphera`
>
> **Legenda:** ✅ Completato · 🔄 In corso · ⬜ Da fare

---

## Analisi App iOS

**Core Mechanics:**
- Ball Sort Puzzle: sposta palline/forme tra tubi finché ogni tubo contiene pezzi identici
- Regole stacking FASE 3: puoi impilare se stesso COLORE **o** stessa FORMA; completo = tutti IDENTICI (colore + forma)
- 5 tipi di forme: ball, cube, pyramid, star, diamond
- 6 tipi di tubi: normal, frozen (top bloccata per N mosse), tall (cap 6), locked (si sblocca quando un tubo è completo), portalA/B (collegati tra loro)
- 8 colori: red, blue, green, yellow, purple, orange, pink, cyan
- 3 difficoltà: easy (3-4 colori), medium (3-6 colori), hard (4-7 colori)

**Sistema Power-ups (acquistati con monete):**
- undoAll (30) — ricomincia livello
- shuffle (50) — rimescola palline
- freezeTimer (75) — ferma timer 30s
- magicWand (120) — completa un tubo
- colorBomb (150) — rimuove tutte le palline di un colore

**Monetizzazione:**
- Monete guadagnate completando livelli (2-10 per livello)
- Power-ups comprati con monete (no IAP)
- AdMob: banner sempre visibile + interstitial ogni 3 livelli + rewarded (guadagna monete/undo/hint)
- Publisher iOS: ca-app-pub-2053215380495624

**Audio:** musica di sottofondo + sound effects
**Localizzazione:** IT / EN (toggle manuale)
**Progressione:** livelli infiniti generati proceduralmente, salvataggio livello corrente per difficoltà

---

## FASE 0 — Setup Progetto ✅

- [x] ✅ Struttura directory e file Gradle
- [x] ✅ `build.gradle.kts` root + app con tutte le dipendenze
- [x] ✅ `settings.gradle.kts`
- [x] ✅ `AndroidManifest.xml`
- [x] ✅ `SphereApp.kt` + `MainActivity.kt`
- [x] ✅ BUILD SUCCESSFUL

---

## FASE 1 — Design System & Theme ✅

- [x] ✅ `Color.kt` — palette dark + 8 colori palline + highlight + shadow
- [x] ✅ `Theme.kt` — MaterialTheme dark-only
- [x] ✅ `Typography.kt` — font di gioco
- [x] ✅ BUILD SUCCESSFUL

---

## FASE 2 — Core Models ✅

- [x] ✅ `BallColor.kt`
- [x] ✅ `ShapeType.kt`
- [x] ✅ `Ball.kt`
- [x] ✅ `TubeType.kt`
- [x] ✅ `Tube.kt` (con PortalColor)
- [x] ✅ `GameMove.kt`
- [x] ✅ `GameState.kt`
- [x] ✅ `MoveResult.kt`
- [x] ✅ `Level.kt` — generazione procedurale, forme, tubi speciali
- [x] ✅ `PowerUpType.kt`
- [x] ✅ `Difficulty.kt`
- [x] ✅ BUILD SUCCESSFUL

---

## FASE 3 — Settings + Localizzazione ✅

- [x] ✅ `L10n.kt` — stringhe IT/EN
- [x] ✅ `SettingsManager.kt` — DataStore persistenza completa
- [x] ✅ `strings.xml` (EN) + `values-it/strings.xml` (IT)
- [x] ✅ BUILD SUCCESSFUL

---

## FASE 4 — Game Logic (GameViewModel) ✅

- [x] ✅ `GameViewModel.kt` — porting completo:
  - stati: gameState, showWinAlert, undoRemaining, hintRemaining
  - timer con freeze power-up
  - undo/hint gratuiti + acquistabili con monete
  - power-ups: undoAll, shuffle, freezeTimer, magicWand, colorBomb
  - extra tube
  - sistema errori (troppi errori → restart)
  - calcolo score + stelle + monete
  - salvataggio livello per difficoltà
  - modalità tester (jump to level)
- [x] ✅ BUILD SUCCESSFUL

---

## FASE 5 — UI: Componenti Gioco ✅

- [x] ✅ `BallView.kt` — Canvas: sfera/cubo/piramide/stella/diamante
- [x] ✅ `TubeView.kt` — tubo con overlay tipi speciali
- [x] ✅ `GameBoard.kt` — griglia tubi adattiva
- [x] ✅ `PowerUpBar.kt` — barra azioni + monete
- [x] ✅ `PowerUpShop.kt` — bottom sheet power-ups
- [x] ✅ `WinDialog.kt` — dialog vittoria con stelle + score
- [x] ✅ `TooManyErrorsDialog.kt`
- [x] ✅ `ShapesTutorialDialog.kt`
- [x] ✅ BUILD SUCCESSFUL

---

## FASE 6 — UI: Schermate Principali ✅

- [x] ✅ `AnimatedBackground.kt` — gradiente dark
- [x] ✅ `SplashScreen.kt`
- [x] ✅ `MenuScreen.kt` — menu con stats, difficoltà, play
- [x] ✅ `GameScreen.kt` — schermata di gioco completa
- [x] ✅ `SettingsScreen.kt` — audio, lingua, reset
- [x] ✅ `TesterPanel.kt` — pannello tester (DEBUG)
- [x] ✅ `SphereNavigation.kt`
- [x] ✅ BUILD SUCCESSFUL

---

## FASE 7 — Audio ✅

- [x] ✅ `AudioManager.kt` — MediaPlayer musica + SoundPool effetti
- [x] ✅ Asset audio in `res/raw/` (copiati dal progetto iOS)
- [x] ✅ BUILD SUCCESSFUL

---

## FASE 8 — AdMob ✅

- [x] ✅ `AdManager.kt` — banner + interstitial + rewarded (ID di test)
- [x] ✅ `BannerAdView.kt` — Composable wrapper
- [x] ✅ App ID AdMob test in AndroidManifest
- [x] ✅ BUILD SUCCESSFUL

---

## FASE 9 — Firebase + Distribuzione ✅

- [x] ✅ Creato progetto Firebase `sphera-puzzle-android`
- [x] ✅ Registrata app Android (package: com.saimonapps.sphera.debug)
- [x] ✅ App ID: `1:160526769606:android:5e0997165fdadfce06a6c7`
- [x] ✅ Creato gruppo `android-testers` (Flavio + Simone)
- [x] ✅ Build debug APK v1.0.0
- [x] ✅ Distribuito via Firebase App Distribution
- [x] ✅ Release ID: `4ij1bvflor9jg`

---

## Note Post-Deploy

- AdMob: usare ID di test fino a quando l'account AdMob Android non sarà configurato
- L'app iOS usa publisher `ca-app-pub-2053215380495624` — creare account AdMob Android separato
- Per la release: creare keystore e configurare `keystore.properties`

---

*Aggiornato: 2026-05-13 — TUTTE LE FASI COMPLETATE. APK v1.0.0 distribuito.*
