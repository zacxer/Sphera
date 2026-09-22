# 🔷 FASE 3: SISTEMA FORME MULTIPLE

## CONTESTO
Ball Sort Puzzle per iOS in SwiftUI. Gioco funzionante + tubi speciali + power-ups. Ora aggiungo la feature DISTINTIVA: forme multiple oltre alle palline.

## ⚠️ REGOLA FONDAMENTALE
**MANTIENI** la grafica glass/riflessi. Le nuove forme devono avere lo stesso livello di qualità visiva delle palline esistenti (3D, glossy, riflessi, ombre).

---

## 🎯 OBIETTIVO
Aggiungere 4 forme geometriche oltre alla pallina. Le forme aggiungono un nuovo layer di strategia al gioco.

---

## 📐 LE FORME

### 1. ⚫ PALLINA (Ball) - Esistente
- Forma base, già implementata
- Cerchio perfetto con effetto 3D glossy

### 2. 🟦 CUBO (Cube)
- Quadrato con angoli arrotondati
- Effetto 3D con facce visibili
- Riflesso sulla faccia superiore

### 3. 🔺 PIRAMIDE (Pyramid)
- Triangolo con effetto 3D
- Punta verso l'alto
- Ombre laterali per profondità

### 4. ⭐ STELLA (Star)
- Stella a 5 punte
- Effetto glow naturale
- Leggermente più piccola per stare nel tubo

### 5. 💎 DIAMANTE (Diamond)
- Rombo/losanga
- Effetto cristallo trasparente
- Riflessi prismatici

---

## 🎮 REGOLE DI GIOCO AGGIORNATE

### Regola Base (Invariata per livelli facili)
> Stesso COLORE può essere impilato insieme

### Nuova Regola (Livelli medi+)
> Per COMPLETARE un tubo servono stesso COLORE **E** stessa FORMA

### Regola Movimento
> Puoi spostare una forma sopra un'altra SE:
> - Hanno lo STESSO COLORE (indipendentemente dalla forma), OPPURE
> - Hanno la STESSA FORMA (indipendentemente dal colore)

**Esempio pratico:**
```
🔴⚫ (pallina rossa) può andare sopra:
  ✅ 🔴🟦 (cubo rosso) - stesso colore
  ✅ 🔵⚫ (pallina blu) - stessa forma
  ❌ 🔵🟦 (cubo blu) - niente in comune

Per COMPLETARE il tubo:
  ✅ 🔴⚫🔴⚫🔴⚫🔴⚫ - 4 palline rosse = COMPLETO
  ❌ 🔴⚫🔴🟦🔴⚫🔴🔺 - rossi ma forme diverse = NON completo
```

---

## 📊 MODELLO DATI

### ShapeType Enum

```swift
enum ShapeType: String, Codable, CaseIterable {
    case ball       // ⚫ Pallina (default)
    case cube       // 🟦 Cubo
    case pyramid    // 🔺 Piramide
    case star       // ⭐ Stella
    case diamond    // 💎 Diamante
    
    var icon: String {
        switch self {
        case .ball: return "circle.fill"
        case .cube: return "square.fill"
        case .pyramid: return "triangle.fill"
        case .star: return "star.fill"
        case .diamond: return "diamond.fill"
        }
    }
    
    var displayName: String {
        switch self {
        case .ball: return "Pallina"
        case .cube: return "Cubo"
        case .pyramid: return "Piramide"
        case .star: return "Stella"
        case .diamond: return "Diamante"
        }
    }
}
```

### Ball Model Aggiornato (rinominare in GamePiece?)

```swift
struct GamePiece: Identifiable, Equatable, Codable {
    let id: UUID
    let color: BallColor
    let shape: ShapeType
    
    init(color: BallColor, shape: ShapeType = .ball) {
        self.id = UUID()
        self.color = color
        self.shape = shape
    }
    
    // Due pezzi possono stare insieme?
    func canStackWith(_ other: GamePiece) -> Bool {
        return self.color == other.color || self.shape == other.shape
    }
    
    // Due pezzi sono identici (per completamento tubo)?
    func isIdenticalTo(_ other: GamePiece) -> Bool {
        return self.color == other.color && self.shape == other.shape
    }
}

// Alias per retrocompatibilità
typealias Ball = GamePiece
```

### Tube Completion Check Aggiornato

```swift
extension Tube {
    // Tubo completo = tutte le forme identiche (colore + forma)
    var isComplete: Bool {
        guard balls.count == capacity else { return false }
        guard let first = balls.first else { return false }
        return balls.allSatisfy { $0.isIdenticalTo(first) }
    }
    
    // Verifica se può accettare un pezzo
    func canAccept(piece: GamePiece) -> Bool {
        if isEmpty { return true }
        if isFull { return false }
        
        guard let topPiece = topBall else { return false }
        return piece.canStackWith(topPiece)
    }
}
```

---

## 🎨 VIEWS PER OGNI FORMA

### GamePieceView (Sostituisce BallView)

```swift
struct GamePieceView: View {
    let piece: GamePiece
    let size: CGFloat
    var isSelected: Bool = false
    
    var body: some View {
        ZStack {
            switch piece.shape {
            case .ball:
                BallShapeView(color: piece.color, size: size)
            case .cube:
                CubeShapeView(color: piece.color, size: size)
            case .pyramid:
                PyramidShapeView(color: piece.color, size: size)
            case .star:
                StarShapeView(color: piece.color, size: size)
            case .diamond:
                DiamondShapeView(color: piece.color, size: size)
            }
        }
        .shadow(color: piece.color.primaryColor.opacity(0.5), radius: isSelected ? 10 : 0)
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}
```

### BallShapeView (Esistente, solo rinominato)

```swift
struct BallShapeView: View {
    let color: BallColor
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Ombra
            Circle()
                .fill(color.shadowColor)
                .blur(radius: 4)
                .offset(y: 3)
            
            // Corpo
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            color.highlightColor,
                            color.primaryColor,
                            color.shadowColor
                        ]),
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: size
                    )
                )
            
            // Riflesso
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.6), .clear],
                        startPoint: .topLeading,
                        endPoint: .center
                    )
                )
                .scaleEffect(0.8)
                .offset(x: -size * 0.15, y: -size * 0.15)
            
            // Punto luce
            Circle()
                .fill(Color.white.opacity(0.9))
                .frame(width: size * 0.2, height: size * 0.2)
                .offset(x: -size * 0.2, y: -size * 0.2)
                .blur(radius: 1)
        }
        .frame(width: size, height: size)
    }
}
```

### CubeShapeView

```swift
struct CubeShapeView: View {
    let color: BallColor
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Ombra
            RoundedRectangle(cornerRadius: size * 0.2)
                .fill(color.shadowColor)
                .blur(radius: 4)
                .offset(y: 3)
            
            // Faccia principale
            RoundedRectangle(cornerRadius: size * 0.2)
                .fill(
                    LinearGradient(
                        colors: [
                            color.highlightColor,
                            color.primaryColor,
                            color.shadowColor
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Bordo 3D - lato destro (più scuro)
            Path { path in
                let corner = size * 0.2
                path.move(to: CGPoint(x: size - corner, y: corner))
                path.addLine(to: CGPoint(x: size, y: 0))
                path.addLine(to: CGPoint(x: size, y: size))
                path.addLine(to: CGPoint(x: size - corner, y: size - corner))
                path.closeSubpath()
            }
            .fill(color.shadowColor.opacity(0.5))
            
            // Bordo 3D - lato superiore (più chiaro)
            Path { path in
                let corner = size * 0.2
                path.move(to: CGPoint(x: corner, y: corner))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: size, y: 0))
                path.addLine(to: CGPoint(x: size - corner, y: corner))
                path.closeSubpath()
            }
            .fill(color.highlightColor.opacity(0.5))
            
            // Riflesso
            RoundedRectangle(cornerRadius: size * 0.15)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.5), .clear],
                        startPoint: .topLeading,
                        endPoint: .center
                    )
                )
                .frame(width: size * 0.6, height: size * 0.6)
                .offset(x: -size * 0.1, y: -size * 0.1)
        }
        .frame(width: size, height: size)
    }
}
```

### PyramidShapeView

```swift
struct PyramidShapeView: View {
    let color: BallColor
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Ombra
            PyramidShape()
                .fill(color.shadowColor)
                .blur(radius: 4)
                .offset(y: 3)
            
            // Faccia sinistra (più scura)
            Path { path in
                path.move(to: CGPoint(x: size / 2, y: 0))
                path.addLine(to: CGPoint(x: 0, y: size))
                path.addLine(to: CGPoint(x: size / 2, y: size * 0.7))
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    colors: [color.primaryColor, color.shadowColor],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            // Faccia destra (più chiara)
            Path { path in
                path.move(to: CGPoint(x: size / 2, y: 0))
                path.addLine(to: CGPoint(x: size, y: size))
                path.addLine(to: CGPoint(x: size / 2, y: size * 0.7))
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    colors: [color.highlightColor, color.primaryColor],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            // Bordo luminoso
            PyramidShape()
                .stroke(color.highlightColor.opacity(0.5), lineWidth: 1)
            
            // Punto luce sulla punta
            Circle()
                .fill(Color.white.opacity(0.8))
                .frame(width: size * 0.15, height: size * 0.15)
                .offset(y: -size * 0.35)
                .blur(radius: 2)
        }
        .frame(width: size, height: size)
    }
}

struct PyramidShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
```

### StarShapeView

```swift
struct StarShapeView: View {
    let color: BallColor
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Glow esterno
            StarShape(points: 5, innerRatio: 0.4)
                .fill(color.primaryColor.opacity(0.3))
                .blur(radius: 8)
                .frame(width: size * 1.2, height: size * 1.2)
            
            // Ombra
            StarShape(points: 5, innerRatio: 0.4)
                .fill(color.shadowColor)
                .blur(radius: 3)
                .offset(y: 2)
            
            // Corpo stella
            StarShape(points: 5, innerRatio: 0.4)
                .fill(
                    RadialGradient(
                        colors: [
                            color.highlightColor,
                            color.primaryColor,
                            color.shadowColor
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size / 2
                    )
                )
            
            // Riflesso centrale
            StarShape(points: 5, innerRatio: 0.4)
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.6), .clear],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: size / 2
                    )
                )
                .scaleEffect(0.6)
                .offset(x: -size * 0.1, y: -size * 0.1)
        }
        .frame(width: size * 0.9, height: size * 0.9) // Leggermente più piccola
    }
}

struct StarShape: Shape {
    let points: Int
    let innerRatio: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * innerRatio
        
        var path = Path()
        let angleIncrement = .pi * 2 / CGFloat(points * 2)
        
        for i in 0..<(points * 2) {
            let radius = i.isMultiple(of: 2) ? outerRadius : innerRadius
            let angle = CGFloat(i) * angleIncrement - .pi / 2
            let point = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )
            
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}
```

### DiamondShapeView

```swift
struct DiamondShapeView: View {
    let color: BallColor
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Ombra
            DiamondShape()
                .fill(color.shadowColor)
                .blur(radius: 4)
                .offset(y: 3)
            
            // Corpo diamante
            DiamondShape()
                .fill(
                    LinearGradient(
                        colors: [
                            color.highlightColor.opacity(0.9),
                            color.primaryColor,
                            color.highlightColor.opacity(0.7),
                            color.shadowColor
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Facce sfaccettate - sinistra
            Path { path in
                path.move(to: CGPoint(x: size / 2, y: 0))
                path.addLine(to: CGPoint(x: 0, y: size / 2))
                path.addLine(to: CGPoint(x: size / 2, y: size / 2))
                path.closeSubpath()
            }
            .fill(color.highlightColor.opacity(0.4))
            
            // Facce sfaccettate - destra
            Path { path in
                path.move(to: CGPoint(x: size / 2, y: 0))
                path.addLine(to: CGPoint(x: size, y: size / 2))
                path.addLine(to: CGPoint(x: size / 2, y: size / 2))
                path.closeSubpath()
            }
            .fill(color.primaryColor.opacity(0.3))
            
            // Riflesso prismatico
            DiamondShape()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.8),
                            Color.clear,
                            Color.white.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
            
            // Punto luce
            Circle()
                .fill(Color.white.opacity(0.9))
                .frame(width: size * 0.15, height: size * 0.15)
                .offset(x: -size * 0.15, y: -size * 0.2)
                .blur(radius: 1)
        }
        .frame(width: size, height: size)
    }
}

struct DiamondShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}
```

---

## 🏗️ LEVEL GENERATOR CON FORME

```swift
struct LevelGenerator {
    
    static func generateLevel(id: Int, colors: Int, shuffleMoves: Int) -> Level {
        // Determina quali forme usare in base alla difficoltà
        let shapes: [ShapeType]
        
        switch id {
        case 1...15:
            // Facile: solo palline
            shapes = [.ball]
            
        case 16...25:
            // Medio: palline + cubi
            shapes = [.ball, .cube]
            
        case 26...35:
            // Difficile: + piramidi
            shapes = [.ball, .cube, .pyramid]
            
        case 36...45:
            // Esperto: + stelle
            shapes = [.ball, .cube, .pyramid, .star]
            
        default:
            // Master: tutte le forme
            shapes = ShapeType.allCases
        }
        
        return generateLevelWithShapes(
            id: id, 
            colors: colors, 
            shapes: shapes, 
            shuffleMoves: shuffleMoves
        )
    }
    
    static func generateLevelWithShapes(
        id: Int,
        colors: Int,
        shapes: [ShapeType],
        shuffleMoves: Int
    ) -> Level {
        
        // Per ogni combinazione colore+forma, crea 4 pezzi
        var allPieces: [GamePiece] = []
        
        let colorsToUse = Array(BallColor.allCases.prefix(colors))
        let shapesToUse = shapes
        
        // Se abbiamo più forme, riduciamo i colori per bilanciare
        let effectiveColors = min(colors, 8 / shapes.count + 1)
        let effectiveColorsArray = Array(colorsToUse.prefix(effectiveColors))
        
        for color in effectiveColorsArray {
            for shape in shapesToUse {
                // 4 pezzi identici per ogni combinazione
                for _ in 0..<4 {
                    allPieces.append(GamePiece(color: color, shape: shape))
                }
            }
        }
        
        // Calcola numero tubi necessari
        let completeSets = allPieces.count / 4
        let numberOfTubes = completeSets + 2 // +2 tubi vuoti
        
        // Crea configurazione iniziale ordinata, poi mescola
        // ...
        
        return Level(
            id: id,
            numberOfColors: effectiveColors,
            numberOfShapes: shapesToUse.count,
            numberOfTubes: numberOfTubes,
            emptyTubes: 2,
            configuration: shuffledConfiguration,
            availableShapes: shapesToUse
        )
    }
}
```

---

## 📱 UI TUTORIAL PER FORME

```swift
struct ShapesTutorialView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Text("🆕 Nuove Forme!")
                .font(.title.bold())
            
            Text("Ora ci sono diverse forme oltre alle palline!")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            // Mostra tutte le forme
            HStack(spacing: 20) {
                ForEach(ShapeType.allCases, id: \.self) { shape in
                    VStack {
                        GamePieceView(
                            piece: GamePiece(color: .blue, shape: shape),
                            size: 40
                        )
                        Text(shape.displayName)
                            .font(.caption)
                    }
                }
            }
            
            Divider()
            
            // Regole
            VStack(alignment: .leading, spacing: 15) {
                RuleRow(
                    icon: "arrow.up.arrow.down",
                    text: "Puoi impilare pezzi con stesso COLORE o stessa FORMA"
                )
                
                RuleRow(
                    icon: "checkmark.circle",
                    text: "Per completare un tubo servono 4 pezzi IDENTICI (stesso colore E forma)"
                )
            }
            
            Button("Ho capito!") {
                isPresented = false
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(30)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 20)
        .padding(40)
    }
}
```

---

## ✅ CHECKLIST IMPLEMENTAZIONE

1. [ ] Crea `ShapeType` enum
2. [ ] Aggiorna `Ball` → `GamePiece` con proprietà `shape`
3. [ ] Aggiorna logica `canStackWith` e `isIdenticalTo`
4. [ ] Crea `GamePieceView` che switcha tra le forme
5. [ ] Implementa `BallShapeView` (rinomina esistente)
6. [ ] Implementa `CubeShapeView` con effetto 3D
7. [ ] Implementa `PyramidShapeView` con facce
8. [ ] Implementa `StarShapeView` con glow
9. [ ] Implementa `DiamondShapeView` con riflessi
10. [ ] Aggiorna `LevelGenerator` per forme
11. [ ] Aggiorna `Tube.isComplete` per forme
12. [ ] Crea tutorial per spiegare le nuove regole
13. [ ] Testa bilanciamento difficoltà
14. [ ] Verifica che livelli 1-15 siano invariati

---

## 🚀 ISTRUZIONI PER CLAUDE CODE

1. Le nuove forme devono avere la STESSA qualità grafica delle palline
2. Mantieni effetti glass, riflessi, ombre, glow
3. Ogni forma deve essere distinguibile a colpo d'occhio
4. Il tutorial appare automaticamente al primo livello con forme
5. Assicurati che la retrocompatibilità con i livelli esistenti funzioni
6. Testa che le nuove regole non creino livelli impossibili
