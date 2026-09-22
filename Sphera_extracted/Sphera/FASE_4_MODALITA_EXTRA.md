# 🏆 FASE 4: MODALITÀ DI GIOCO EXTRA

## CONTESTO
Ball Sort Puzzle per iOS con tubi speciali, power-ups e forme multiple. Ora aggiungo modalità di gioco alternative per aumentare la retention.

---

## 🎯 NUOVE MODALITÀ

---

## 1. 📅 DAILY CHALLENGE (Sfida Giornaliera)

### Concept
- UN puzzle al giorno, uguale per TUTTI i giocatori nel mondo
- Classifica globale basata su mosse/tempo
- Streak bonus per giorni consecutivi

### Meccaniche
```swift
struct DailyChallenge: Codable {
    let date: Date
    let seed: Int // Seed per generare lo stesso puzzle per tutti
    let difficulty: Difficulty
    let configuration: [[GamePiece]]
    
    static func forToday() -> DailyChallenge {
        let today = Calendar.current.startOfDay(for: Date())
        let seed = Int(today.timeIntervalSince1970)
        
        // Usa il seed per generare puzzle deterministico
        var rng = SeededRandomNumberGenerator(seed: seed)
        
        // Difficoltà basata sul giorno della settimana
        let weekday = Calendar.current.component(.weekday, from: today)
        let difficulty: Difficulty = weekday == 1 ? .expert : // Domenica = difficile
                                     weekday == 7 ? .hard :   // Sabato = medio-difficile
                                     .medium                   // Altri giorni = medio
        
        return DailyChallenge(
            date: today,
            seed: seed,
            difficulty: difficulty,
            configuration: generatePuzzle(with: &rng, difficulty: difficulty)
        )
    }
}
```

### UI Daily Challenge

```swift
struct DailyChallengeView: View {
    @StateObject private var viewModel = DailyChallengeViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            // Header con data
            HStack {
                VStack(alignment: .leading) {
                    Text("SFIDA DEL GIORNO")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formattedDate)
                        .font(.title2.bold())
                }
                
                Spacer()
                
                // Streak
                VStack {
                    Text("🔥 \(viewModel.currentStreak)")
                        .font(.title.bold())
                    Text("giorni")
                        .font(.caption)
                }
                .padding()
                .background(Color.orange.opacity(0.2))
                .cornerRadius(12)
            }
            
            // Stato completamento
            if viewModel.hasCompletedToday {
                CompletedBadgeView(
                    moves: viewModel.todayMoves,
                    rank: viewModel.todayRank,
                    totalPlayers: viewModel.totalPlayers
                )
            } else {
                // Pulsante Gioca
                Button(action: { viewModel.startChallenge() }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("GIOCA ORA")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "FF6B6B"), Color(hex: "FF8E53")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                }
            }
            
            // Timer prossima sfida
            Text("Prossima sfida tra: \(viewModel.timeUntilNextChallenge)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Divider()
            
            // Classifica
            LeaderboardView(entries: viewModel.leaderboard)
        }
        .padding()
    }
}

struct LeaderboardView: View {
    let entries: [LeaderboardEntry]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("🏆 CLASSIFICA")
                .font(.headline)
            
            ForEach(entries.prefix(10)) { entry in
                HStack {
                    // Rank
                    Text("\(entry.rank)")
                        .font(.system(.body, design: .monospaced))
                        .frame(width: 30)
                    
                    // Medal for top 3
                    if entry.rank <= 3 {
                        Text(entry.rank == 1 ? "🥇" : entry.rank == 2 ? "🥈" : "🥉")
                    }
                    
                    // Name
                    Text(entry.playerName)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Moves
                    Text("\(entry.moves) mosse")
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
                .background(entry.isCurrentPlayer ? Color.blue.opacity(0.2) : .clear)
                .cornerRadius(8)
            }
        }
    }
}
```

### Persistenza Daily Challenge

```swift
class DailyChallengeManager {
    static let shared = DailyChallengeManager()
    
    private let defaults = UserDefaults.standard
    
    var currentStreak: Int {
        get { defaults.integer(forKey: "dailyStreak") }
        set { defaults.set(newValue, forKey: "dailyStreak") }
    }
    
    var lastCompletedDate: Date? {
        get { defaults.object(forKey: "lastDailyCompleted") as? Date }
        set { defaults.set(newValue, forKey: "lastDailyCompleted") }
    }
    
    var hasCompletedToday: Bool {
        guard let last = lastCompletedDate else { return false }
        return Calendar.current.isDateInToday(last)
    }
    
    func completeChallenge(moves: Int) {
        let today = Date()
        
        // Aggiorna streak
        if let last = lastCompletedDate {
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
            if Calendar.current.isDate(last, inSameDayAs: yesterday) {
                currentStreak += 1
            } else if !Calendar.current.isDateInToday(last) {
                currentStreak = 1 // Reset streak
            }
        } else {
            currentStreak = 1
        }
        
        lastCompletedDate = today
        saveTodayResult(moves: moves)
    }
}
```

---

## 2. ♾️ ENDLESS MODE (Modalità Infinita)

### Concept
- Puzzle infiniti generati proceduralmente
- Difficoltà crescente progressiva
- High score basato su livelli completati consecutivamente
- 3 vite - perdi una vita se fai troppe mosse o resetti

### Meccaniche

```swift
struct EndlessMode {
    var currentWave: Int = 1
    var lives: Int = 3
    var totalScore: Int = 0
    var consecutiveCompletes: Int = 0
    
    // Difficoltà scala con le wave
    var currentDifficulty: EndlessDifficulty {
        switch currentWave {
        case 1...5: return .starter
        case 6...15: return .easy
        case 16...30: return .medium
        case 31...50: return .hard
        default: return .insane
        }
    }
    
    // Mosse massime concesse (basate sulla difficoltà)
    var maxMoves: Int {
        currentDifficulty.baseMoves + (currentWave * 2)
    }
    
    // Punti per completamento
    func calculateScore(moves: Int) -> Int {
        let baseScore = 100 * currentWave
        let moveBonus = max(0, (maxMoves - moves) * 10)
        let comboMultiplier = 1.0 + (Double(consecutiveCompletes) * 0.1)
        
        return Int(Double(baseScore + moveBonus) * comboMultiplier)
    }
}

enum EndlessDifficulty {
    case starter, easy, medium, hard, insane
    
    var colors: Int {
        switch self {
        case .starter: return 2
        case .easy: return 3
        case .medium: return 4
        case .hard: return 5
        case .insane: return 6
        }
    }
    
    var tubes: Int { colors + 2 }
    var baseMoves: Int { colors * 10 }
    var includesSpecialTubes: Bool { self >= .medium }
    var includesShapes: Bool { self >= .hard }
}
```

### UI Endless Mode

```swift
struct EndlessModeView: View {
    @StateObject private var viewModel = EndlessModeViewModel()
    
    var body: some View {
        ZStack {
            // Game area (riusa GameView esistente)
            GameView(viewModel: viewModel.gameViewModel)
            
            // Overlay HUD Endless
            VStack {
                EndlessHUD(
                    wave: viewModel.currentWave,
                    lives: viewModel.lives,
                    score: viewModel.totalScore,
                    movesLeft: viewModel.movesRemaining
                )
                Spacer()
            }
            
            // Game Over overlay
            if viewModel.isGameOver {
                EndlessGameOverView(
                    finalWave: viewModel.currentWave,
                    finalScore: viewModel.totalScore,
                    isNewHighScore: viewModel.isNewHighScore,
                    onRestart: { viewModel.restart() },
                    onExit: { /* dismiss */ }
                )
            }
        }
    }
}

struct EndlessHUD: View {
    let wave: Int
    let lives: Int
    let score: Int
    let movesLeft: Int
    
    var body: some View {
        HStack {
            // Wave
            VStack(alignment: .leading) {
                Text("WAVE")
                    .font(.caption)
                Text("\(wave)")
                    .font(.title.bold())
            }
            
            Spacer()
            
            // Lives
            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Image(systemName: i < lives ? "heart.fill" : "heart")
                        .foregroundColor(i < lives ? .red : .gray)
                }
            }
            
            Spacer()
            
            // Score
            VStack(alignment: .trailing) {
                Text("SCORE")
                    .font(.caption)
                Text("\(score)")
                    .font(.title.bold())
            }
        }
        .padding()
        .background(Color.black.opacity(0.5))
    }
}
```

---

## 3. ⏱️ SPEED RUN MODE

### Concept
- 10 livelli predefiniti
- Timer globale - completali tutti il più veloce possibile
- Classifiche per tempo totale
- Nessun aiuto disponibile (no undo, no hints)

### Meccaniche

```swift
struct SpeedRun: Codable, Identifiable {
    let id: UUID
    let difficulty: SpeedRunDifficulty
    let levels: [Level] // 10 livelli predefiniti
    var currentLevelIndex: Int = 0
    var totalTime: TimeInterval = 0
    var levelTimes: [TimeInterval] = []
    var isCompleted: Bool = false
    
    enum SpeedRunDifficulty: String, CaseIterable {
        case bronze  // Facile
        case silver  // Medio
        case gold    // Difficile
        case diamond // Esperto
        
        var color: Color {
            switch self {
            case .bronze: return Color(hex: "CD7F32")
            case .silver: return Color(hex: "C0C0C0")
            case .gold: return Color(hex: "FFD700")
            case .diamond: return Color(hex: "B9F2FF")
            }
        }
        
        var targetTime: TimeInterval {
            switch self {
            case .bronze: return 300  // 5 minuti
            case .silver: return 240  // 4 minuti
            case .gold: return 180    // 3 minuti
            case .diamond: return 120 // 2 minuti
            }
        }
    }
}

struct SpeedRunViewModel: ObservableObject {
    @Published var speedRun: SpeedRun
    @Published var currentTime: TimeInterval = 0
    @Published var levelStartTime: Date = Date()
    
    private var timer: Timer?
    
    func startRun() {
        levelStartTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateTime()
        }
    }
    
    func completeLevel() {
        let levelTime = Date().timeIntervalSince(levelStartTime)
        speedRun.levelTimes.append(levelTime)
        speedRun.totalTime += levelTime
        
        if speedRun.currentLevelIndex < 9 {
            speedRun.currentLevelIndex += 1
            levelStartTime = Date()
        } else {
            finishRun()
        }
    }
    
    private func finishRun() {
        timer?.invalidate()
        speedRun.isCompleted = true
        
        // Salva high score
        SpeedRunManager.shared.saveResult(speedRun)
    }
}
```

### UI Speed Run

```swift
struct SpeedRunView: View {
    @StateObject private var viewModel: SpeedRunViewModel
    
    var body: some View {
        ZStack {
            // Game
            GameView(viewModel: viewModel.gameViewModel)
                .disabled(viewModel.isPaused)
            
            // Timer overlay
            VStack {
                SpeedRunTimerBar(
                    currentTime: viewModel.currentTime,
                    targetTime: viewModel.speedRun.difficulty.targetTime,
                    levelProgress: viewModel.speedRun.currentLevelIndex + 1
                )
                Spacer()
            }
            
            // Completion overlay
            if viewModel.speedRun.isCompleted {
                SpeedRunResultView(
                    totalTime: viewModel.speedRun.totalTime,
                    targetTime: viewModel.speedRun.difficulty.targetTime,
                    levelTimes: viewModel.speedRun.levelTimes,
                    isNewRecord: viewModel.isNewRecord
                )
            }
        }
    }
}

struct SpeedRunTimerBar: View {
    let currentTime: TimeInterval
    let targetTime: TimeInterval
    let levelProgress: Int
    
    var progressColor: Color {
        let ratio = currentTime / targetTime
        if ratio < 0.5 { return .green }
        if ratio < 0.8 { return .yellow }
        return .red
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Timer grande
            Text(formatTime(currentTime))
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.2))
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 4)
                        .fill(progressColor)
                        .frame(width: geo.size.width * min(currentTime / targetTime, 1.0))
                }
            }
            .frame(height: 8)
            
            // Level indicator
            HStack(spacing: 4) {
                ForEach(1...10, id: \.self) { level in
                    Circle()
                        .fill(level <= levelProgress ? progressColor : Color.white.opacity(0.3))
                        .frame(width: 10, height: 10)
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.7))
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let tenths = Int((time.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%d:%02d.%d", minutes, seconds, tenths)
    }
}
```

---

## 📱 MENU SELEZIONE MODALITÀ

```swift
struct GameModesView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Classica
                GameModeCard(
                    title: "CLASSICA",
                    subtitle: "50 livelli di puzzle",
                    icon: "square.grid.3x3",
                    color: .blue,
                    destination: LevelSelectView()
                )
                
                // Daily Challenge
                GameModeCard(
                    title: "SFIDA GIORNALIERA",
                    subtitle: "Un puzzle al giorno per tutti",
                    icon: "calendar",
                    color: .orange,
                    badge: DailyChallengeBadge(),
                    destination: DailyChallengeView()
                )
                
                // Endless
                GameModeCard(
                    title: "INFINITA",
                    subtitle: "Quanto lontano puoi arrivare?",
                    icon: "infinity",
                    color: .purple,
                    destination: EndlessModeView()
                )
                
                // Speed Run
                GameModeCard(
                    title: "SPEED RUN",
                    subtitle: "10 livelli contro il tempo",
                    icon: "timer",
                    color: .red,
                    destination: SpeedRunSelectView()
                )
            }
            .padding()
        }
    }
}

struct GameModeCard<Destination: View>: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    var badge: AnyView? = nil
    let destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 15) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(color)
                    .cornerRadius(15)
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Badge (es. streak, high score)
                badge
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(16)
        }
    }
}
```

---

## ✅ CHECKLIST IMPLEMENTAZIONE

### Daily Challenge
1. [ ] Crea `DailyChallenge` model con generazione deterministica
2. [ ] Implementa `SeededRandomNumberGenerator`
3. [ ] Crea `DailyChallengeView` con UI
4. [ ] Implementa sistema streak
5. [ ] Crea leaderboard (locale per ora, poi online)
6. [ ] Timer countdown per prossima sfida

### Endless Mode
7. [ ] Crea `EndlessMode` model
8. [ ] Implementa scaling difficoltà
9. [ ] Sistema vite
10. [ ] Score con combo multiplier
11. [ ] High score persistence
12. [ ] Game Over screen

### Speed Run
13. [ ] Crea `SpeedRun` model
14. [ ] 4 difficoltà predefinite
15. [ ] Timer in tempo reale
16. [ ] Progress bar visiva
17. [ ] Risultati con split times
18. [ ] Leaderboard per difficoltà

### UI
19. [ ] Menu selezione modalità
20. [ ] Card per ogni modalità
21. [ ] Badge/indicatori (streak, high score)

---

## 🚀 ISTRUZIONI PER CLAUDE CODE

1. Crea le 3 nuove modalità come schermate separate
2. Riutilizza `GameView` esistente dove possibile
3. Ogni modalità ha il suo ViewModel dedicato
4. La leaderboard per ora è solo locale (UserDefaults)
5. Mantieni la grafica consistente con il resto dell'app
