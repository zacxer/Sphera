# ⚡ FASE 5: SISTEMA COMBO & PALLINE SPECIALI

## CONTESTO
Ball Sort Puzzle con tutte le feature precedenti. Aggiungo meccaniche che rendono il gameplay più dinamico e rewarding.

---

## 🔥 PARTE 1: SISTEMA COMBO

### Concept
Quando completi tubi in rapida successione, ottieni bonus combo che aumentano il punteggio.

### Meccaniche

```swift
struct ComboSystem {
    var currentCombo: Int = 0
    var comboTimer: TimeInterval = 0
    var maxComboTime: TimeInterval = 3.0 // Secondi per mantenere il combo
    var totalBonusPoints: Int = 0
    
    var multiplier: Double {
        switch currentCombo {
        case 0: return 1.0
        case 1: return 1.2
        case 2: return 1.5
        case 3: return 2.0
        case 4: return 2.5
        default: return 3.0 // Max x3
        }
    }
    
    var comboLabel: String {
        guard currentCombo > 0 else { return "" }
        return "x\(String(format: "%.1f", multiplier))"
    }
    
    mutating func tubeCompleted(baseScore: Int) -> Int {
        currentCombo += 1
        comboTimer = maxComboTime
        
        let bonusScore = Int(Double(baseScore) * multiplier) - baseScore
        totalBonusPoints += bonusScore
        
        return bonusScore
    }
    
    mutating func tick(_ deltaTime: TimeInterval) {
        if currentCombo > 0 {
            comboTimer -= deltaTime
            if comboTimer <= 0 {
                resetCombo()
            }
        }
    }
    
    mutating func resetCombo() {
        currentCombo = 0
        comboTimer = 0
    }
}
```

### UI Combo

```swift
struct ComboOverlayView: View {
    let combo: Int
    let multiplier: Double
    let timeRemaining: TimeInterval
    let maxTime: TimeInterval
    
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0
    
    var body: some View {
        VStack(spacing: 5) {
            // Combo text
            Text("COMBO")
                .font(.caption.bold())
                .foregroundColor(.white.opacity(0.7))
            
            // Multiplier
            Text("x\(String(format: "%.1f", multiplier))")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundColor(comboColor)
                .shadow(color: comboColor.opacity(0.5), radius: 10)
            
            // Timer bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(comboColor)
                        .frame(width: geo.size.width * (timeRemaining / maxTime))
                }
            }
            .frame(width: 80, height: 4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(comboColor.opacity(0.5), lineWidth: 2)
                )
        )
        .scaleEffect(scale)
        .opacity(opacity)
        .onChange(of: combo) { _ in
            animatePop()
        }
    }
    
    var comboColor: Color {
        switch combo {
        case 1: return .yellow
        case 2: return .orange
        case 3: return .red
        case 4: return .purple
        default: return Color(hex: "FF00FF") // Magenta per max combo
        }
    }
    
    func animatePop() {
        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
            scale = 1.3
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring()) {
                scale = 1.0
            }
        }
    }
}

// Popup bonus points quando completi un tubo
struct BonusPointsPopup: View {
    let points: Int
    let position: CGPoint
    
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1
    
    var body: some View {
        Text("+\(points)")
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundColor(.yellow)
            .shadow(color: .orange, radius: 5)
            .position(position)
            .offset(y: offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    offset = -50
                    opacity = 0
                }
            }
    }
}
```

---

## 🌟 PARTE 2: PALLINE SPECIALI

### 1. 🌈 PALLINA ARCOBALENO (Rainbow Ball)
**Effetto:** Funziona come JOLLY - vale come qualsiasi colore

```swift
extension BallColor {
    static let rainbow = BallColor.special(.rainbow)
}

enum SpecialBallType {
    case rainbow    // 🌈 Vale come qualsiasi colore
    case bomb       // 💣 Esplode se non la rimuovi in X mosse
    case golden     // ⭐ Bonus punti doppi
    case frozen     // 🧊 Deve essere "scongelata" prima di muoverla
}

struct GamePiece {
    // ... existing properties ...
    var specialType: SpecialBallType?
    
    var isRainbow: Bool { specialType == .rainbow }
    
    // Rainbow può andare con qualsiasi colore
    func canStackWith(_ other: GamePiece) -> Bool {
        if self.isRainbow || other.isRainbow {
            return true // Rainbow sempre compatibile
        }
        return self.color == other.color || self.shape == other.shape
    }
}
```

**Grafica Rainbow Ball:**
```swift
struct RainbowBallView: View {
    let size: CGFloat
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // Glow animato
            Circle()
                .fill(
                    AngularGradient(
                        colors: [.red, .orange, .yellow, .green, .blue, .purple, .red],
                        center: .center
                    )
                )
                .blur(radius: 10)
                .opacity(0.5)
            
            // Corpo pallina
            Circle()
                .fill(
                    AngularGradient(
                        colors: [.red, .orange, .yellow, .green, .blue, .purple, .red],
                        center: .center,
                        startAngle: .degrees(rotation),
                        endAngle: .degrees(rotation + 360)
                    )
                )
            
            // Riflesso
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.8), .clear],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: size * 0.7
                    )
                )
                .scaleEffect(0.9)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}
```

---

### 2. 💣 PALLINA BOMBA (Bomb Ball)
**Effetto:** Ha un countdown. Se arriva a 0, GAME OVER (o perdi una vita in Endless)

```swift
struct BombBall {
    var countdown: Int = 10 // Mosse rimanenti
    
    mutating func tick() {
        countdown -= 1
    }
    
    var isAboutToExplode: Bool { countdown <= 3 }
    var hasExploded: Bool { countdown <= 0 }
}
```

**Grafica Bomb Ball:**
```swift
struct BombBallView: View {
    let color: BallColor
    let countdown: Int
    let size: CGFloat
    
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            // Pallina base
            BallShapeView(color: color, size: size)
            
            // Overlay bomba
            ZStack {
                // Miccia
                Path { path in
                    path.move(to: CGPoint(x: size * 0.7, y: size * 0.1))
                    path.addQuadCurve(
                        to: CGPoint(x: size * 0.9, y: -size * 0.1),
                        control: CGPoint(x: size * 0.85, y: size * 0.05)
                    )
                }
                .stroke(Color.brown, lineWidth: 2)
                
                // Scintilla
                if countdown <= 5 {
                    Circle()
                        .fill(countdown <= 3 ? Color.red : Color.orange)
                        .frame(width: 8, height: 8)
                        .offset(x: size * 0.35, y: -size * 0.35)
                        .scaleEffect(isPulsing ? 1.5 : 1.0)
                }
                
                // Countdown number
                Text("\(countdown)")
                    .font(.system(size: size * 0.4, weight: .black))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 2)
            }
            
            // Red pulse warning
            if countdown <= 3 {
                Circle()
                    .stroke(Color.red, lineWidth: 3)
                    .scaleEffect(isPulsing ? 1.3 : 1.0)
                    .opacity(isPulsing ? 0 : 0.8)
            }
        }
        .onAppear {
            if countdown <= 5 {
                withAnimation(.easeInOut(duration: 0.5).repeatForever()) {
                    isPulsing = true
                }
            }
        }
    }
}
```

---

### 3. ⭐ PALLINA DORATA (Golden Ball)
**Effetto:** Vale punti doppi quando completi il tubo che la contiene

```swift
struct GoldenBall {
    var pointsMultiplier: Double = 2.0
}
```

**Grafica Golden Ball:**
```swift
struct GoldenBallView: View {
    let color: BallColor // Il colore base
    let size: CGFloat
    
    @State private var shimmerOffset: CGFloat = -1
    
    var body: some View {
        ZStack {
            // Glow dorato
            Circle()
                .fill(Color(hex: "FFD700").opacity(0.4))
                .blur(radius: 15)
            
            // Pallina con tinta dorata
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "FFF8DC"), // Light gold
                            Color(hex: "FFD700"), // Gold
                            Color(hex: "DAA520"), // Dark gold
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: size
                    )
                )
            
            // Shimmer effect
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.6), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: size * 0.3)
                .offset(x: shimmerOffset * size)
                .mask(Circle())
            
            // Stellina
            Image(systemName: "star.fill")
                .font(.system(size: size * 0.3))
                .foregroundColor(.white)
                .shadow(color: Color(hex: "FFD700"), radius: 3)
            
            // Colore indicator (piccolo cerchio)
            Circle()
                .fill(color.primaryColor)
                .frame(width: size * 0.25, height: size * 0.25)
                .offset(x: size * 0.25, y: size * 0.25)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 1)
                        .frame(width: size * 0.25, height: size * 0.25)
                        .offset(x: size * 0.25, y: size * 0.25)
                )
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                shimmerOffset = 1
            }
        }
    }
}
```

---

### 4. 🧊 PALLINA CONGELATA (Frozen Ball)
**Effetto:** Non può essere mossa finché non "scongeli" toccandola 3 volte

```swift
struct FrozenBall {
    var tapCount: Int = 0
    let tapsRequired: Int = 3
    
    var isFrozen: Bool { tapCount < tapsRequired }
    
    mutating func tap() {
        tapCount += 1
    }
}
```

**Grafica Frozen Ball:**
```swift
struct FrozenBallView: View {
    let color: BallColor
    let tapsRemaining: Int
    let size: CGFloat
    
    @State private var crackLevel: Int = 0
    
    var body: some View {
        ZStack {
            // Pallina base (desaturata)
            BallShapeView(color: color, size: size)
                .saturation(0.3)
                .brightness(-0.1)
            
            // Strato di ghiaccio
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "E0FFFF").opacity(0.7),
                            Color(hex: "87CEEB").opacity(0.5),
                            Color(hex: "ADD8E6").opacity(0.3)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.6
                    )
                )
            
            // Crepe nel ghiaccio
            if crackLevel >= 1 {
                CrackPattern(level: crackLevel)
                    .stroke(Color.white.opacity(0.8), lineWidth: 1)
            }
            
            // Tap indicator
            VStack(spacing: 2) {
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: size * 0.25))
                Text("\(tapsRemaining)")
                    .font(.system(size: size * 0.2, weight: .bold))
            }
            .foregroundColor(.white)
            .shadow(color: .black, radius: 2)
            
            // Cristalli di ghiaccio decorativi
            ForEach(0..<6) { i in
                Image(systemName: "snowflake")
                    .font(.system(size: size * 0.1))
                    .foregroundColor(.white.opacity(0.6))
                    .offset(
                        x: cos(CGFloat(i) * .pi / 3) * size * 0.35,
                        y: sin(CGFloat(i) * .pi / 3) * size * 0.35
                    )
            }
        }
        .frame(width: size, height: size)
        .onChange(of: tapsRemaining) { newValue in
            crackLevel = 3 - newValue
        }
    }
}

struct CrackPattern: Shape {
    let level: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        // Disegna crepe in base al livello
        for i in 0..<(level * 2) {
            let angle = CGFloat(i) * .pi / CGFloat(level)
            let length = rect.width * 0.3 * CGFloat(level) / 3
            
            path.move(to: center)
            path.addLine(to: CGPoint(
                x: center.x + cos(angle) * length,
                y: center.y + sin(angle) * length
            ))
        }
        
        return path
    }
}
```

---

## 🎮 INTEGRAZIONE NEL GAMEPLAY

### Spawn delle Palline Speciali

```swift
struct LevelGenerator {
    static func addSpecialBalls(to level: inout Level) {
        // Probabilità basata sulla difficoltà
        let rainbowChance: Double
        let bombChance: Double
        let goldenChance: Double
        let frozenChance: Double
        
        switch level.difficulty {
        case .easy:
            rainbowChance = 0.05
            bombChance = 0
            goldenChance = 0.03
            frozenChance = 0
        case .medium:
            rainbowChance = 0.08
            bombChance = 0.03
            goldenChance = 0.05
            frozenChance = 0.03
        case .hard:
            rainbowChance = 0.1
            bombChance = 0.05
            goldenChance = 0.05
            frozenChance = 0.05
        case .expert:
            rainbowChance = 0.1
            bombChance = 0.08
            goldenChance = 0.08
            frozenChance = 0.08
        }
        
        // Applica le probabilità ai pezzi esistenti
        for tubeIndex in level.configuration.indices {
            for ballIndex in level.configuration[tubeIndex].indices {
                let roll = Double.random(in: 0...1)
                
                if roll < rainbowChance {
                    level.configuration[tubeIndex][ballIndex].specialType = .rainbow
                } else if roll < rainbowChance + bombChance {
                    level.configuration[tubeIndex][ballIndex].specialType = .bomb
                } else if roll < rainbowChance + bombChance + goldenChance {
                    level.configuration[tubeIndex][ballIndex].specialType = .golden
                } else if roll < rainbowChance + bombChance + goldenChance + frozenChance {
                    level.configuration[tubeIndex][ballIndex].specialType = .frozen
                }
            }
        }
    }
}
```

### GameViewModel Updates

```swift
class GameViewModel: ObservableObject {
    // ... existing code ...
    
    @Published var comboSystem = ComboSystem()
    @Published var bonusPopups: [BonusPopup] = []
    
    private var comboTimer: Timer?
    
    func startComboTimer() {
        comboTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.comboSystem.tick(0.1)
            self?.objectWillChange.send()
        }
    }
    
    func handleTubeCompletion(at tubeIndex: Int) {
        // Calcola punti base
        var basePoints = 100
        
        // Bonus per palline dorate
        let goldenCount = gameState.tubes[tubeIndex].balls.filter { $0.specialType == .golden }.count
        basePoints += goldenCount * 100
        
        // Applica combo
        let bonusPoints = comboSystem.tubeCompleted(baseScore: basePoints)
        
        // Mostra popup bonus
        if bonusPoints > 0 {
            let popup = BonusPopup(
                id: UUID(),
                points: bonusPoints,
                position: getTubePosition(tubeIndex)
            )
            bonusPopups.append(popup)
            
            // Rimuovi dopo animazione
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.bonusPopups.removeAll { $0.id == popup.id }
            }
        }
        
        // Suono e haptic
        SoundManager.shared.play(.tubeComplete)
        HapticManager.shared.success()
    }
    
    func handleBombTick() {
        for tubeIndex in gameState.tubes.indices {
            for ballIndex in gameState.tubes[tubeIndex].balls.indices {
                if gameState.tubes[tubeIndex].balls[ballIndex].specialType == .bomb {
                    // Tick the bomb
                    gameState.tubes[tubeIndex].balls[ballIndex].bombCountdown -= 1
                    
                    if gameState.tubes[tubeIndex].balls[ballIndex].bombCountdown <= 0 {
                        // BOOM!
                        handleBombExplosion()
                    }
                }
            }
        }
    }
    
    func handleFrozenBallTap(tubeIndex: Int, ballIndex: Int) {
        guard var ball = gameState.tubes[tubeIndex].balls[safe: ballIndex],
              ball.specialType == .frozen,
              ball.frozenTapsRemaining > 0 else { return }
        
        ball.frozenTapsRemaining -= 1
        gameState.tubes[tubeIndex].balls[ballIndex] = ball
        
        SoundManager.shared.play(.freeze_tick)
        HapticManager.shared.lightTap()
        
        if ball.frozenTapsRemaining <= 0 {
            // Scongelata!
            gameState.tubes[tubeIndex].balls[ballIndex].specialType = nil
            SoundManager.shared.play(.unfreeze)
            HapticManager.shared.success()
        }
    }
}
```

---

## 🔊 NUOVI SUONI

| File | Descrizione |
|------|-------------|
| `combo_1.mp3` | Combo x1.2 (ding) |
| `combo_2.mp3` | Combo x1.5 (ding più alto) |
| `combo_3.mp3` | Combo x2.0 (fanfara breve) |
| `combo_max.mp3` | Combo MAX (fanfara epica) |
| `combo_break.mp3` | Combo perso (sad trombone) |
| `rainbow_place.mp3` | Pallina rainbow piazzata |
| `bomb_tick.mp3` | Tick bomba |
| `bomb_warning.mp3` | Bomba in pericolo |
| `bomb_explode.mp3` | Esplosione |
| `golden_complete.mp3` | Tubo con golden completato |
| `ice_tap.mp3` | Tap su pallina frozen |
| `ice_break.mp3` | Pallina scongelata |

---

## ✅ CHECKLIST IMPLEMENTAZIONE

### Sistema Combo
1. [ ] Crea `ComboSystem` struct
2. [ ] Timer per combo decay
3. [ ] UI `ComboOverlayView`
4. [ ] Popup bonus points animati
5. [ ] Suoni per ogni livello combo
6. [ ] Integra nel `GameViewModel`

### Palline Speciali
7. [ ] Aggiungi `SpecialBallType` enum
8. [ ] Implementa `RainbowBallView`
9. [ ] Implementa `BombBallView` con countdown
10. [ ] Implementa `GoldenBallView` con shimmer
11. [ ] Implementa `FrozenBallView` con crepe
12. [ ] Logica spawn in `LevelGenerator`
13. [ ] Gestione tap per Frozen balls
14. [ ] Gestione countdown Bomb
15. [ ] Calcolo punti Golden

---

## 🚀 ISTRUZIONI PER CLAUDE CODE

1. Il sistema combo è globale e persiste tra i livelli in Endless Mode
2. Le palline speciali devono mantenere lo stile grafico glass esistente
3. La Rainbow ball ha animazione continua (gradient rotante)
4. La Bomb ball ha warning crescente quando countdown < 3
5. I popup bonus devono essere animati (float up + fade out)
6. Tutti gli effetti devono avere feedback haptic appropriato
