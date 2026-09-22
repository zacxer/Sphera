# ⚡ FASE 2: POWER-UPS

## CONTESTO
Ball Sort Puzzle per iOS in SwiftUI. Gioco base funzionante + tubi speciali (Fase 1). Ora aggiungo sistema Power-Ups per aiutare il giocatore e monetizzazione.

## ⚠️ REGOLA FONDAMENTALE
**NON MODIFICARE** la grafica esistente. Mantieni lo stile glass/riflessi. Aggiungi SOLO i power-ups come nuovo layer.

---

## 🎯 OBIETTIVO
Aggiungere 5 power-ups che il giocatore può usare durante il gioco.

---

## 🧰 POWER-UPS

### 1. 🪄 BACCHETTA MAGICA (Magic Wand)
**Effetto:** Cambia il colore di UNA pallina a scelta in qualsiasi altro colore

**Come funziona:**
1. Giocatore preme icona bacchetta
2. Entra in "modalità selezione" - tutte le palline pulsano
3. Tocca la pallina da cambiare
4. Appare picker colori (solo colori presenti nel livello)
5. Seleziona nuovo colore → pallina cambia con animazione magica

**Grafica:**
- Icona: bacchetta con stelline
- Colore: viola/magenta
- Animazione uso: sparkles + pallina che brilla e cambia

```swift
struct MagicWandPowerUp: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var isSelectionMode = false
    @State private var showColorPicker = false
    @State private var selectedBallIndex: (tube: Int, ball: Int)?
    
    var body: some View {
        Button(action: { activateWand() }) {
            PowerUpButton(
                icon: "wand.and.stars",
                color: Color(hex: "A855F7"),
                count: viewModel.powerUps.magicWandCount,
                isActive: isSelectionMode
            )
        }
        .disabled(viewModel.powerUps.magicWandCount <= 0)
    }
}
```

---

### 2. 💣 BOMBA COLORE (Color Bomb)
**Effetto:** Elimina TUTTE le palline di UN colore specifico dal gioco

**Come funziona:**
1. Giocatore preme icona bomba
2. Appare selezione colori disponibili
3. Seleziona colore → BOOM! Tutte le palline di quel colore scompaiono
4. I tubi si "compattano" (le palline scendono)

**Grafica:**
- Icona: bomba con miccia
- Colore: rosso/arancione
- Animazione: esplosione + palline che si disintegrano con particelle

```swift
struct ColorBombPowerUp: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var showColorSelection = false
    
    var availableColors: [BallColor] {
        // Colori presenti nel gioco attuale
        var colors = Set<BallColor>()
        for tube in viewModel.gameState.tubes {
            for ball in tube.balls {
                colors.insert(ball.color)
            }
        }
        return Array(colors).sorted { $0.rawValue < $1.rawValue }
    }
    
    func detonateBomb(color: BallColor) {
        // Rimuovi tutte le palline del colore
        for i in 0..<viewModel.gameState.tubes.count {
            viewModel.gameState.tubes[i].balls.removeAll { $0.color == color }
        }
        
        // Animazione esplosione
        // Suono bomba
        // Decrementa contatore
    }
}
```

---

### 3. 🔀 SHUFFLE (Mescola Tutto)
**Effetto:** Rimescola casualmente TUTTE le palline in tutti i tubi

**Come funziona:**
1. Preme shuffle
2. Conferma (alert: "Sei sicuro? Le palline verranno rimescolate!")
3. Tutte le palline volano e si ridistribuiscono casualmente
4. Rischio/ricompensa: potrebbe migliorare o peggiorare la situazione!

**Grafica:**
- Icona: frecce incrociate
- Colore: blu elettrico
- Animazione: tutte le palline volano in aria e ricadono

```swift
struct ShufflePowerUp: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var showConfirmation = false
    
    func performShuffle() {
        // Raccogli tutte le palline
        var allBalls: [Ball] = []
        for tube in viewModel.gameState.tubes {
            allBalls.append(contentsOf: tube.balls)
        }
        
        // Mescola
        allBalls.shuffle()
        
        // Ridistribuisci nei tubi (rispettando capacità)
        var ballIndex = 0
        for i in 0..<viewModel.gameState.tubes.count {
            viewModel.gameState.tubes[i].balls.removeAll()
            
            let capacity = viewModel.gameState.tubes[i].capacity
            let ballsToAdd = min(capacity, allBalls.count - ballIndex)
            
            for _ in 0..<ballsToAdd {
                if ballIndex < allBalls.count {
                    viewModel.gameState.tubes[i].balls.append(allBalls[ballIndex])
                    ballIndex += 1
                }
            }
        }
        
        // Lascia almeno 2 tubi vuoti
        // ...
    }
}
```

---

### 4. ⏱️ FREEZE TIME (Solo se c'è timer)
**Effetto:** Blocca il timer per 30 secondi

**Come funziona:**
1. Preme freeze
2. Timer si ferma + effetto ghiaccio sullo schermo
3. Dopo 30 secondi riparte

**Grafica:**
- Icona: orologio con fiocco neve
- Colore: ciano/azzurro
- Animazione: cristalli di ghiaccio ai bordi dello schermo

```swift
struct FreezeTimePowerUp: View {
    @ObservedObject var viewModel: GameViewModel
    
    // Solo visibile se il livello ha timer attivo
    var body: some View {
        if viewModel.currentLevelHasTimer {
            Button(action: { freezeTimer() }) {
                PowerUpButton(
                    icon: "clock.badge.checkmark",
                    color: Color(hex: "06B6D4"),
                    count: viewModel.powerUps.freezeTimeCount,
                    isActive: viewModel.isTimerFrozen
                )
            }
        }
    }
}
```

---

### 5. ↩️ UNDO INFINITO (Super Undo)
**Effetto:** Annulla TUTTE le mosse e torna all'inizio del livello (senza perdere vite/tentativi)

**Come funziona:**
1. Preme super undo
2. Conferma
3. Il livello si resetta ma mantieni i power-ups

**Grafica:**
- Icona: freccia circolare con "∞"
- Colore: verde
- Animazione: rewind veloce di tutte le mosse

```swift
struct SuperUndoPowerUp: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var showConfirmation = false
    
    func performSuperUndo() {
        // Torna alla configurazione iniziale
        viewModel.resetLevelKeepPowerUps()
        
        // Animazione rewind
        // Suono rewind
    }
}
```

---

## 📊 MODELLO DATI POWER-UPS

```swift
struct PowerUps: Codable {
    var magicWandCount: Int
    var colorBombCount: Int
    var shuffleCount: Int
    var freezeTimeCount: Int
    var superUndoCount: Int
    
    static let initial = PowerUps(
        magicWandCount: 3,
        colorBombCount: 2,
        shuffleCount: 2,
        freezeTimeCount: 3,
        superUndoCount: 1
    )
    
    mutating func useMagicWand() { magicWandCount = max(0, magicWandCount - 1) }
    mutating func useColorBomb() { colorBombCount = max(0, colorBombCount - 1) }
    mutating func useShuffle() { shuffleCount = max(0, shuffleCount - 1) }
    mutating func useFreezeTime() { freezeTimeCount = max(0, freezeTimeCount - 1) }
    mutating func useSuperUndo() { superUndoCount = max(0, superUndoCount - 1) }
}
```

---

## 🎨 UI POWER-UPS BAR

```swift
struct PowerUpsBar: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        HStack(spacing: 15) {
            MagicWandPowerUp(viewModel: viewModel)
            ColorBombPowerUp(viewModel: viewModel)
            ShufflePowerUp(viewModel: viewModel)
            if viewModel.currentLevelHasTimer {
                FreezeTimePowerUp(viewModel: viewModel)
            }
            SuperUndoPowerUp(viewModel: viewModel)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct PowerUpButton: View {
    let icon: String
    let color: Color
    let count: Int
    var isActive: Bool = false
    
    var body: some View {
        ZStack {
            // Background
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            color.opacity(0.4),
                            color.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 50, height: 50)
                .overlay(
                    Circle()
                        .stroke(color.opacity(isActive ? 1 : 0.5), lineWidth: 2)
                )
                .shadow(color: isActive ? color.opacity(0.5) : .clear, radius: 10)
            
            // Icon
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(count > 0 ? .white : .gray)
            
            // Counter badge
            if count > 0 {
                Text("\(count)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 18, height: 18)
                    .background(color)
                    .clipShape(Circle())
                    .offset(x: 18, y: -18)
            }
            
            // Empty state
            if count <= 0 {
                Circle()
                    .fill(Color.black.opacity(0.5))
                    .frame(width: 50, height: 50)
            }
        }
        .scaleEffect(isActive ? 1.1 : 1.0)
        .animation(.spring(response: 0.3), value: isActive)
    }
}
```

---

## 💰 SISTEMA OTTENIMENTO POWER-UPS

### Metodi gratuiti:
1. **Reward per livello completato** - 1 power-up random ogni 5 livelli
2. **Daily Bonus** - Login giornaliero = 1 power-up random
3. **Achievement** - Completa sfide = power-ups

### Metodi con Ads:
1. **Watch Ad** - Guarda video pubblicitario = 1 power-up a scelta
2. **Ad on Fail** - Quando perdi, offri "Guarda ad per 1 aiuto"

### Acquisti In-App (futuro):
1. Pack Starter: 5 di ogni power-up
2. Pack Mega: 20 di ogni power-up
3. Abbonamento: Power-ups infiniti

```swift
struct PowerUpShop: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Ottieni Power-Ups")
                .font(.title2.bold())
            
            // Watch Ad Button
            Button(action: { showRewardedAd() }) {
                HStack {
                    Image(systemName: "play.rectangle.fill")
                    Text("Guarda Video")
                    Spacer()
                    Text("+1 Power-Up")
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            }
            
            // Daily Bonus (se disponibile)
            if viewModel.isDailyBonusAvailable {
                Button(action: { claimDailyBonus() }) {
                    HStack {
                        Image(systemName: "gift.fill")
                            .foregroundColor(.yellow)
                        Text("Bonus Giornaliero")
                        Spacer()
                        Text("GRATIS")
                            .foregroundColor(.green)
                    }
                    .padding()
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(12)
                }
            }
        }
    }
}
```

---

## 💾 PERSISTENZA POWER-UPS

```swift
class GameDataManager {
    // ... existing code ...
    
    private let powerUpsKey = "playerPowerUps"
    private let lastDailyBonusKey = "lastDailyBonus"
    
    var powerUps: PowerUps {
        get {
            guard let data = defaults.data(forKey: powerUpsKey),
                  let powerUps = try? JSONDecoder().decode(PowerUps.self, from: data) else {
                return PowerUps.initial
            }
            return powerUps
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: powerUpsKey)
            }
        }
    }
    
    var isDailyBonusAvailable: Bool {
        guard let lastClaim = defaults.object(forKey: lastDailyBonusKey) as? Date else {
            return true // Mai reclamato
        }
        return !Calendar.current.isDateInToday(lastClaim)
    }
    
    func claimDailyBonus() -> PowerUps.PowerUpType {
        defaults.set(Date(), forKey: lastDailyBonusKey)
        
        // Random power-up
        let types: [PowerUps.PowerUpType] = [.magicWand, .colorBomb, .shuffle, .freezeTime, .superUndo]
        return types.randomElement()!
    }
}
```

---

## 🔊 NUOVI SUONI

| File | Descrizione |
|------|-------------|
| `powerup_select.mp3` | Selezione power-up |
| `magic_wand.mp3` | Bacchetta magica (sparkle) |
| `color_bomb.mp3` | Esplosione bomba |
| `shuffle.mp3` | Whoosh mescola |
| `freeze_time.mp3` | Cristalli ghiaccio |
| `super_undo.mp3` | Rewind tape |
| `powerup_earned.mp3` | Hai ottenuto power-up! |

---

## 📍 POSIZIONAMENTO UI

```
┌─────────────────────────────────┐
│  ← LIVELLO 3        ↺ Reset     │  Header
├─────────────────────────────────┤
│                                 │
│     [Tube] [Tube] [Tube]        │
│     [Tube] [Tube] [Tube]        │  Game Area
│                                 │
├─────────────────────────────────┤
│  [🪄 3] [💣 2] [🔀 2] [↩️ 1]    │  Power-Ups Bar (NUOVO)
├─────────────────────────────────┤
│    [Annulla]    [Suggerisci]    │  Controls
└─────────────────────────────────┘
```

---

## ✅ CHECKLIST IMPLEMENTAZIONE

1. [ ] Crea modello `PowerUps`
2. [ ] Aggiungi `powerUps` al `GameViewModel`
3. [ ] Crea `PowerUpButton` component riutilizzabile
4. [ ] Crea `PowerUpsBar` view
5. [ ] Implementa logica `MagicWand` + color picker
6. [ ] Implementa logica `ColorBomb` + animazione esplosione
7. [ ] Implementa logica `Shuffle` + conferma
8. [ ] Implementa logica `FreezeTime` (se c'è timer)
9. [ ] Implementa logica `SuperUndo`
10. [ ] Aggiungi persistenza power-ups
11. [ ] Crea `PowerUpShop` per ottenere power-ups
12. [ ] Sistema daily bonus
13. [ ] Animazioni per ogni power-up
14. [ ] Suoni (opzionali)

---

## 🚀 ISTRUZIONI PER CLAUDE CODE

1. Aggiungi il sistema power-ups al progetto esistente
2. La `PowerUpsBar` va posizionata sopra i controlli esistenti (Annulla/Suggerisci)
3. Mantieni la grafica glass esistente
4. I power-ups devono essere persistenti tra le sessioni
5. Il daily bonus usa il calendario locale del device
6. Per ora NON implementare gli ads reali - solo placeholder
