# 🚀 PROMPT CLAUDE CODE - SPLASH SCREEN SPHERA

## CONTESTO
Sto sviluppando il gioco **SPHERA** (Ball Sort Puzzle) per iOS in SwiftUI. Ho già l'immagine di sfondo pronta in:
```
Assets.xcassets/SplashBackground.imageset/SplashBackground.png
```

Devi creare una **Splash Screen animata** che appare all'avvio dell'app per 3-4 secondi prima di mostrare il menu principale.

---

## 🎯 OBIETTIVO

Creare `SplashScreenView.swift` e modificare l'app entry point per mostrare la splash screen all'avvio con animazioni premium.

---

## 📱 STRUTTURA SPLASH SCREEN

```
┌─────────────────────────────────┐
│                                 │
│    ✨ particelle fluttuanti ✨   │
│                                 │
│                                 │
│         S P H E R A             │  ← Titolo con glow viola
│                                 │
│   The Ultimate Ball Sorting     │  ← Tagline
│           Puzzle                │
│                                 │
│      ● ● ● (loading dots)       │  ← Indicatore caricamento
│                                 │
│    [IMMAGINE SFONDO CON         │
│     TUBI E PALLINE]             │
│                                 │
│                                 │
└─────────────────────────────────┘
```

---

## 📄 FILE DA CREARE: `SplashScreenView.swift`

```swift
import SwiftUI

struct SplashScreenView: View {
    // MARK: - Animation States
    @State private var logoOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.8
    @State private var taglineOpacity: Double = 0
    @State private var dotsOpacity: Double = 0
    @State private var currentDot: Int = 0
    @State private var shimmerOffset: CGFloat = -200
    @State private var particlesVisible: Bool = false
    
    // Timer per i dots animati
    let dotsTimer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // LAYER 1: Immagine di sfondo
            Image("SplashBackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            // LAYER 2: Overlay scuro per far risaltare il testo
            LinearGradient(
                colors: [
                    Color.black.opacity(0.6),
                    Color.black.opacity(0.2),
                    Color.clear,
                    Color.black.opacity(0.3)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // LAYER 3: Particelle fluttuanti
            if particlesVisible {
                ParticlesView()
                    .ignoresSafeArea()
            }
            
            // LAYER 4: Contenuto principale
            VStack(spacing: 20) {
                Spacer()
                    .frame(height: 100)
                
                // LOGO "SPHERA"
                ZStack {
                    // Glow effect dietro il testo
                    Text("SPHERA")
                        .font(.system(size: 56, weight: .black, design: .rounded))
                        .foregroundColor(Color(hex: "A855F7"))
                        .blur(radius: 20)
                        .opacity(logoOpacity * 0.8)
                    
                    // Testo principale
                    Text("SPHERA")
                        .font(.system(size: 56, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color(hex: "E0E0E0")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: Color(hex: "A855F7").opacity(0.8), radius: 15, x: 0, y: 0)
                        .shadow(color: Color(hex: "7C3AED").opacity(0.5), radius: 30, x: 0, y: 5)
                        .tracking(8) // Letter spacing
                        .overlay(
                            // Shimmer effect
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            .clear,
                                            .white.opacity(0.4),
                                            .clear
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 80)
                                .offset(x: shimmerOffset)
                                .mask(
                                    Text("SPHERA")
                                        .font(.system(size: 56, weight: .black, design: .rounded))
                                        .tracking(8)
                                )
                        )
                }
                .opacity(logoOpacity)
                .scaleEffect(logoScale)
                
                // TAGLINE
                Text("The Ultimate Ball Sorting Puzzle")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .tracking(2)
                    .opacity(taglineOpacity)
                
                Spacer()
                
                // LOADING DOTS
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.white)
                            .frame(width: 10, height: 10)
                            .scaleEffect(currentDot == index ? 1.3 : 1.0)
                            .opacity(currentDot == index ? 1.0 : 0.4)
                            .animation(.easeInOut(duration: 0.3), value: currentDot)
                    }
                }
                .opacity(dotsOpacity)
                .padding(.bottom, 80)
            }
        }
        .onAppear {
            startAnimations()
        }
        .onReceive(dotsTimer) { _ in
            currentDot = (currentDot + 1) % 3
        }
    }
    
    // MARK: - Animations
    private func startAnimations() {
        // Particelle appaiono subito
        withAnimation(.easeIn(duration: 0.5)) {
            particlesVisible = true
        }
        
        // Logo fade in + scale
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3)) {
            logoOpacity = 1
            logoScale = 1
        }
        
        // Tagline fade in
        withAnimation(.easeOut(duration: 0.6).delay(0.8)) {
            taglineOpacity = 1
        }
        
        // Loading dots
        withAnimation(.easeOut(duration: 0.4).delay(1.2)) {
            dotsOpacity = 1
        }
        
        // Shimmer effect continuo
        withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false).delay(1.0)) {
            shimmerOffset = 200
        }
    }
}

// MARK: - Particles View
struct ParticlesView: View {
    let particleCount = 30
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<particleCount, id: \.self) { index in
                    ParticleView(
                        screenSize: geometry.size,
                        delay: Double(index) * 0.1
                    )
                }
            }
        }
    }
}

struct ParticleView: View {
    let screenSize: CGSize
    let delay: Double
    
    @State private var opacity: Double = 0
    @State private var position: CGPoint = .zero
    @State private var scale: CGFloat = 1
    
    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: CGFloat.random(in: 2...6), height: CGFloat.random(in: 2...6))
            .opacity(opacity)
            .scaleEffect(scale)
            .position(position)
            .onAppear {
                position = CGPoint(
                    x: CGFloat.random(in: 0...screenSize.width),
                    y: CGFloat.random(in: 0...screenSize.height)
                )
                
                // Fade in
                withAnimation(.easeIn(duration: Double.random(in: 1...2)).delay(delay)) {
                    opacity = Double.random(in: 0.3...0.8)
                }
                
                // Float animation
                withAnimation(
                    .easeInOut(duration: Double.random(in: 3...6))
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    position.y -= CGFloat.random(in: 20...50)
                    scale = CGFloat.random(in: 0.8...1.2)
                }
            }
    }
}

// MARK: - Color Extension (se non esiste già)
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview
#Preview {
    SplashScreenView()
}
```

---

## 📄 FILE DA MODIFICARE: App Entry Point

Modifica il file principale dell'app (probabilmente `SphereApp.swift` o `BallSortPuzzleApp.swift`) per mostrare prima la splash screen:

```swift
import SwiftUI

@main
struct SpheraApp: App {
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Main content
                MainMenuView() // o ContentView() - il tuo menu principale
                    .opacity(showSplash ? 0 : 1)
                
                // Splash screen
                if showSplash {
                    SplashScreenView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .onAppear {
                // Dopo 3.5 secondi, nascondi splash
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showSplash = false
                    }
                }
            }
        }
    }
}
```

---

## 🎨 SPECIFICHE DESIGN

### Logo "SPHERA"
| Proprietà | Valore |
|-----------|--------|
| Font | System Black Rounded |
| Size | 56pt |
| Color | Bianco con gradient |
| Letter Spacing | 8pt |
| Glow Color | #A855F7 (viola) |
| Glow Radius | 15-30px |
| Animazione | Fade in + Scale (0.8→1.0) + Shimmer |

### Tagline
| Proprietà | Valore |
|-----------|--------|
| Font | System Medium Rounded |
| Size | 16pt |
| Color | Bianco 70% opacity |
| Letter Spacing | 2pt |
| Animazione | Fade in con delay 0.8s |

### Particelle
| Proprietà | Valore |
|-----------|--------|
| Quantità | 30 particelle |
| Size | 2-6px random |
| Color | Bianco |
| Opacity | 30-80% random |
| Animazione | Float up/down continuo |

### Timing
| Evento | Tempo |
|--------|-------|
| Particelle appaiono | 0.5s |
| Logo appare | 0.3s delay |
| Tagline appare | 0.8s delay |
| Loading dots | 1.2s delay |
| Transizione a menu | 3.5s totali |

---

## ✅ CHECKLIST IMPLEMENTAZIONE

1. [ ] Crea `SplashScreenView.swift` con tutto il codice sopra
2. [ ] Verifica che `Color(hex:)` extension esista (altrimenti aggiungila)
3. [ ] Modifica l'App entry point per mostrare splash first
4. [ ] Verifica che "SplashBackground" sia accessibile da Assets
5. [ ] Testa su simulatore iPhone
6. [ ] Testa su simulatore iPad
7. [ ] Verifica che la transizione al menu sia smooth

---

## 🚀 ISTRUZIONI

1. **NON modificare** altri file esistenti tranne l'entry point dell'app
2. Se `Color(hex:)` esiste già nel progetto, **non duplicarla**
3. L'immagine di sfondo è già in `Assets.xcassets/SplashBackground`
4. Mantieni lo stesso stile visivo del resto dell'app
5. La splash deve funzionare sia su **iPhone** che su **iPad**
6. Se trovi il nome del file App diverso (es: `BallSortPuzzleApp.swift`), modifica quello

---

## 💡 NOTE EXTRA

- Lo shimmer sul logo crea un effetto "luce che passa" premium
- Le particelle danno vita allo sfondo statico
- I loading dots indicano che l'app sta caricando
- La transizione fade-out è smooth e professionale
- Il glow viola richiama i colori del gioco
