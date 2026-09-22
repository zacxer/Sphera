# 🧪 FASE 1: TUBI SPECIALI

## CONTESTO
Sto sviluppando Ball Sort Puzzle per iOS in SwiftUI. Il gioco base è già funzionante con grafica glass/riflessi bellissima. Ora voglio aggiungere TUBI SPECIALI per differenziare il gioco dalla concorrenza.

## ⚠️ REGOLA FONDAMENTALE
**NON MODIFICARE** la grafica esistente delle palline e dei tubi normali. La grafica attuale è perfetta (effetto glass, riflessi, glow). Aggiungi SOLO le nuove funzionalità mantenendo lo stesso stile visivo.

---

## 🎯 OBIETTIVO
Aggiungere 5 tipi di tubi speciali che appaiono nei livelli medi/difficili.

---

## 📦 NUOVI TIPI DI TUBI

### 1. 🧊 TUBO GHIACCIATO (Frozen Tube)
**Meccanica:**
- La pallina in FONDO al tubo è congelata/bloccata
- Non può essere spostata finché non si "scongela"
- Si scongela dopo 3 mosse globali (qualsiasi mossa nel gioco)
- Mostra un contatore sopra il tubo: "❄️ 3" → "❄️ 2" → "❄️ 1" → sbloccato

**Grafica:**
- Tubo con tonalità blu/ciano
- Effetto brina/ghiaccio sul bordo
- Pallina in fondo ha overlay semi-trasparente di ghiaccio
- Particelle di neve/cristalli che fluttuano (subtle)
- Quando si scongela: animazione di rottura ghiaccio + suono

```swift
struct FrozenTubeOverlay: View {
    let freezeCountdown: Int // 3, 2, 1, 0
    
    var body: some View {
        ZStack {
            // Effetto brina sui bordi del tubo
            RoundedRectangle(cornerRadius: 25)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(hex: "A8E6FF").opacity(0.8),
                            Color(hex: "00D4FF").opacity(0.4),
                            Color(hex: "A8E6FF").opacity(0.6)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 4
                )
            
            // Cristalli di ghiaccio decorativi
            // ...
            
            // Countdown badge
            if freezeCountdown > 0 {
                VStack {
                    HStack(spacing: 4) {
                        Image(systemName: "snowflake")
                        Text("\(freezeCountdown)")
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(hex: "00D4FF").opacity(0.8))
                    .cornerRadius(12)
                    Spacer()
                }
                .padding(.top, -30)
            }
        }
    }
}
```

---

### 2. ⬆️ TUBO ALTO (Tall Tube)
**Meccanica:**
- Contiene 6 palline invece di 4
- Richiede quindi 6 palline dello stesso colore per completarlo
- Occupa più spazio verticale sullo schermo

**Grafica:**
- Stesso stile glass dei tubi normali
- Semplicemente più alto (1.5x)
- Leggero glow dorato per distinguerlo

```swift
struct TallTube: Identifiable, Codable {
    // capacity = 6 invece di 4
    let capacity: Int = 6
    
    // Badge visivo
    var heightBadge: some View {
        HStack(spacing: 2) {
            Image(systemName: "arrow.up")
            Text("x6")
        }
        .font(.system(size: 10, weight: .bold))
        .foregroundColor(Color(hex: "FFD700"))
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color(hex: "FFD700").opacity(0.2))
        .cornerRadius(8)
    }
}
```

---

### 3. 🔒 TUBO BLOCCATO (Locked Tube)
**Meccanica:**
- Inizia bloccato - non puoi metterci palline né prenderle
- Si sblocca quando completi un tubo specifico (indicato da una linea/connessione visiva)
- Oppure: si sblocca dopo X mosse

**Grafica:**
- Tubo scuro/opaco con lucchetto sopra
- Catene decorative ai lati (subtle)
- Quando si sblocca: animazione lucchetto che si apre + catene che cadono

```swift
struct LockedTubeOverlay: View {
    let isLocked: Bool
    @State private var unlockAnimation = false
    
    var body: some View {
        ZStack {
            if isLocked {
                // Overlay scuro
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.black.opacity(0.6))
                
                // Lucchetto
                Image(systemName: "lock.fill")
                    .font(.system(size: 30))
                    .foregroundColor(Color(hex: "FF6B6B"))
                    .shadow(color: Color(hex: "FF6B6B").opacity(0.5), radius: 10)
            }
        }
        .onChange(of: isLocked) { newValue in
            if !newValue {
                // Trigger unlock animation
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    unlockAnimation = true
                }
                // Play unlock sound
                SoundManager.shared.play(.tubeUnlock)
                HapticManager.shared.success()
            }
        }
    }
}
```

---

### 4. 🌀 TUBO PORTALE (Portal Tube)
**Meccanica:**
- Sempre in coppia con un altro tubo portale (stesso colore portale)
- Quando metti una pallina nel portale A, esce dal portale B (e viceversa)
- La pallina va in CIMA al tubo di destinazione
- Non puoi usare il portale se il tubo destinazione è pieno

**Grafica:**
- Anello luminoso colorato attorno al tubo (es. viola/magenta)
- Particelle che ruotano attorno
- I due portali collegati hanno lo stesso colore anello
- Animazione "risucchio" quando la pallina entra

```swift
enum PortalColor: String, CaseIterable {
    case purple, orange, cyan
    
    var color: Color {
        switch self {
        case .purple: return Color(hex: "A855F7")
        case .orange: return Color(hex: "F97316")
        case .cyan: return Color(hex: "06B6D4")
        }
    }
}

struct PortalTubeOverlay: View {
    let portalColor: PortalColor
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // Anello esterno rotante
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [
                            portalColor.color,
                            portalColor.color.opacity(0.3),
                            portalColor.color
                        ],
                        center: .center
                    ),
                    lineWidth: 4
                )
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }
            
            // Glow effect
            Circle()
                .fill(portalColor.color.opacity(0.2))
                .frame(width: 70, height: 70)
                .blur(radius: 10)
            
            // Icona portale
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(portalColor.color)
        }
        .offset(y: -20) // Posiziona sopra il tubo
    }
}
```

---

### 5. 🔄 TUBO ROTANTE (Rotating Tube)
**Meccanica:**
- Ogni 2 mosse globali, le palline al suo interno si INVERTONO
- Es: [Rosso, Blu, Verde, Giallo] → [Giallo, Verde, Blu, Rosso]
- Mostra un indicatore "⟳ 2" → "⟳ 1" → RUOTA → "⟳ 2"
- Aggiunge imprevedibilità strategica

**Grafica:**
- Frecce circolari decorative attorno al tubo
- Quando ruota: animazione flip/rotate delle palline
- Colore accento arancione

```swift
struct RotatingTubeOverlay: View {
    let rotateCountdown: Int // 2, 1, 0 (0 = ruota ora)
    @State private var isRotating = false
    
    var body: some View {
        ZStack {
            // Frecce rotanti decorative
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 24))
                .foregroundColor(Color(hex: "F97316"))
                .rotationEffect(.degrees(isRotating ? 360 : 0))
                .offset(y: -25)
            
            // Countdown badge
            HStack(spacing: 4) {
                Image(systemName: "arrow.clockwise")
                Text("\(rotateCountdown)")
            }
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(hex: "F97316").opacity(0.8))
            .cornerRadius(10)
            .offset(y: 100) // Sotto il tubo
        }
    }
    
    func triggerRotation() {
        withAnimation(.easeInOut(duration: 0.5)) {
            isRotating = true
        }
        // Reset after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isRotating = false
        }
    }
}
```

---

## 📊 MODELLO DATI AGGIORNATO

### TubeType Enum

```swift
enum TubeType: String, Codable, CaseIterable {
    case normal
    case frozen
    case tall
    case locked
    case portalA  // Portal pair A
    case portalB  // Portal pair B (linked to A)
    case rotating
    
    var capacity: Int {
        switch self {
        case .tall: return 6
        default: return 4
        }
    }
    
    var displayName: String {
        switch self {
        case .normal: return "Normale"
        case .frozen: return "Ghiacciato"
        case .tall: return "Alto"
        case .locked: return "Bloccato"
        case .portalA, .portalB: return "Portale"
        case .rotating: return "Rotante"
        }
    }
    
    var icon: String {
        switch self {
        case .normal: return "cylinder"
        case .frozen: return "snowflake"
        case .tall: return "arrow.up"
        case .locked: return "lock.fill"
        case .portalA, .portalB: return "arrow.triangle.2.circlepath"
        case .rotating: return "arrow.clockwise"
        }
    }
}
```

### Tube Model Aggiornato

```swift
struct Tube: Identifiable, Equatable, Codable {
    let id: UUID
    var balls: [Ball]
    let type: TubeType
    
    // Stato specifico per tipo
    var freezeCountdown: Int? // Per frozen
    var isLocked: Bool? // Per locked
    var linkedPortalId: UUID? // Per portal
    var rotateCountdown: Int? // Per rotating
    
    var capacity: Int { type.capacity }
    
    init(balls: [Ball] = [], type: TubeType = .normal) {
        self.id = UUID()
        self.balls = balls
        self.type = type
        
        // Inizializza stato in base al tipo
        switch type {
        case .frozen:
            self.freezeCountdown = 3
        case .locked:
            self.isLocked = true
        case .rotating:
            self.rotateCountdown = 2
        default:
            break
        }
    }
    
    // Frozen: la pallina in fondo è bloccata?
    var isBottomBallFrozen: Bool {
        guard type == .frozen else { return false }
        return (freezeCountdown ?? 0) > 0 && !balls.isEmpty
    }
    
    // Può accettare pallina considerando tipo speciale
    func canAccept(ball: Ball) -> Bool {
        // Locked tube
        if type == .locked && (isLocked ?? false) {
            return false
        }
        
        // Normal rules
        if isFull { return false }
        if isEmpty { return true }
        return topBall?.color == ball.color
    }
    
    // Può rimuovere pallina considerando tipo speciale
    func canRemoveTop() -> Bool {
        if isEmpty { return false }
        
        // Frozen: se c'è solo 1 pallina ed è frozen, non può
        if type == .frozen && balls.count == 1 && isBottomBallFrozen {
            return false
        }
        
        // Locked
        if type == .locked && (isLocked ?? false) {
            return false
        }
        
        return true
    }
}
```

---

## 🎮 GAME STATE AGGIORNATO

```swift
struct GameState: Codable {
    var tubes: [Tube]
    var selectedTubeIndex: Int?
    var moveCount: Int
    var moveHistory: [Move]
    let levelId: Int
    
    // Chiamato dopo ogni mossa
    mutating func processSpecialTubes() {
        for i in 0..<tubes.count {
            switch tubes[i].type {
            case .frozen:
                // Decrementa countdown
                if let countdown = tubes[i].freezeCountdown, countdown > 0 {
                    tubes[i].freezeCountdown = countdown - 1
                    if tubes[i].freezeCountdown == 0 {
                        // Trigger unfreeze animation/sound
                    }
                }
                
            case .rotating:
                // Decrementa e ruota se necessario
                if let countdown = tubes[i].rotateCountdown, countdown > 0 {
                    tubes[i].rotateCountdown = countdown - 1
                    if tubes[i].rotateCountdown == 0 {
                        // Inverti palline
                        tubes[i].balls.reverse()
                        tubes[i].rotateCountdown = 2 // Reset
                        // Trigger rotate animation
                    }
                }
                
            default:
                break
            }
        }
    }
    
    // Gestione portali
    mutating func handlePortalMove(ball: Ball, toTubeIndex: Int) -> Int? {
        let tube = tubes[toTubeIndex]
        
        guard tube.type == .portalA || tube.type == .portalB else {
            return nil
        }
        
        // Trova il tubo portale collegato
        guard let linkedId = tube.linkedPortalId,
              let linkedIndex = tubes.firstIndex(where: { $0.id == linkedId }) else {
            return nil
        }
        
        // Verifica che il tubo destinazione possa accettare
        if tubes[linkedIndex].canAccept(ball: ball) {
            return linkedIndex // La pallina va qui
        }
        
        return nil // Portale bloccato, mossa normale
    }
}
```

---

## 🏗️ LEVEL GENERATOR AGGIORNATO

```swift
struct LevelGenerator {
    
    static func generateLevel(id: Int, colors: Int, shuffleMoves: Int) -> Level {
        var tubeTypes: [TubeType] = []
        
        // Determina quali tubi speciali in base alla difficoltà
        switch id {
        case 1...15:
            // Facile: solo tubi normali
            tubeTypes = Array(repeating: .normal, count: colors + 2)
            
        case 16...25:
            // Medio: introduci frozen e tall
            tubeTypes = Array(repeating: .normal, count: colors)
            if id > 18 { tubeTypes[0] = .frozen }
            if id > 22 { tubeTypes.append(.tall) } else { tubeTypes.append(.normal) }
            tubeTypes.append(.normal) // Tubo vuoto extra
            
        case 26...35:
            // Difficile: frozen, tall, locked
            tubeTypes = Array(repeating: .normal, count: colors)
            tubeTypes[0] = .frozen
            tubeTypes[1] = .locked
            if id > 30 { tubeTypes[2] = .tall }
            tubeTypes.append(.normal)
            tubeTypes.append(.normal)
            
        case 36...45:
            // Esperto: aggiungi portali
            tubeTypes = Array(repeating: .normal, count: colors)
            tubeTypes[0] = .frozen
            tubeTypes[1] = .portalA
            tubeTypes[2] = .portalB
            if id > 40 { tubeTypes[3] = .rotating }
            tubeTypes.append(.tall)
            tubeTypes.append(.normal)
            
        default:
            // Master: tutto!
            tubeTypes = Array(repeating: .normal, count: colors)
            tubeTypes[0] = .frozen
            tubeTypes[1] = .rotating
            tubeTypes[2] = .portalA
            tubeTypes[3] = .portalB
            tubeTypes.append(.tall)
            tubeTypes.append(.locked)
            tubeTypes.append(.normal)
        }
        
        // Genera configurazione con i tipi specificati
        return generateLevelWithTypes(id: id, colors: colors, tubeTypes: tubeTypes, shuffleMoves: shuffleMoves)
    }
}
```

---

## 🔊 NUOVI SUONI DA AGGIUNGERE

| File | Descrizione |
|------|-------------|
| `freeze_tick.mp3` | Tick countdown ghiaccio |
| `unfreeze.mp3` | Ghiaccio che si rompe |
| `tube_unlock.mp3` | Lucchetto che si apre |
| `portal_enter.mp3` | Whoosh risucchio portale |
| `portal_exit.mp3` | Whoosh uscita portale |
| `tube_rotate.mp3` | Suono rotazione/flip |

---

## ✅ CHECKLIST IMPLEMENTAZIONE

1. [ ] Crea `TubeType` enum
2. [ ] Aggiorna modello `Tube` con tipo e stati speciali
3. [ ] Crea le 5 overlay views per ogni tipo di tubo speciale
4. [ ] Aggiorna `TubeView` per mostrare overlay in base al tipo
5. [ ] Aggiorna `GameState` con logica `processSpecialTubes()`
6. [ ] Implementa logica portali
7. [ ] Aggiorna `LevelGenerator` per includere tubi speciali
8. [ ] Aggiungi animazioni (freeze, unlock, rotate, portal)
9. [ ] Aggiungi suoni (opzionali, il gioco funziona anche senza)
10. [ ] Aggiorna tutorial/help per spiegare i nuovi tubi
11. [ ] Testa tutti i casi edge (portale pieno, frozen + locked, ecc.)

---

## 🚀 ISTRUZIONI PER CLAUDE CODE

Implementa i tubi speciali nel progetto esistente:
1. **NON ricreare tutto** - modifica solo i file necessari
2. **Mantieni la grafica glass/riflessi** esistente
3. Aggiungi i nuovi tipi uno alla volta se preferisci
4. Assicurati che i livelli 1-15 rimangano invariati (solo tubi normali)
5. I suoni sono opzionali - usa i placeholder se non esistono
6. Testa che i livelli esistenti funzionino ancora!
