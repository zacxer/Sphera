# 🧙‍♂️ FASE 6: STORIA & PERSONAGGIO

## CONTESTO
Ball Sort Puzzle con tutte le feature gameplay. Ora aggiungo un layer narrativo per dare motivazione al giocatore e aumentare l'engagement.

---

## 🎭 CONCEPT STORIA

### Protagonista: Il Piccolo Alchimista
- Nome: **Lumi** (o personalizzabile dal giocatore)
- Aspetto: Piccolo apprendista alchimista con cappello da mago troppo grande
- Obiettivo: Ordinare le pozioni magiche per salvare il suo maestro

### Trama Breve
> *Il Maestro Alchimista è stato colpito da una maledizione!*
> *L'unico modo per salvarlo è creare l'Elisir della Guarigione.*
> *Ma il laboratorio è nel caos totale - tutte le pozioni sono mescolate!*
> *Aiuta Lumi a riordinare le pozioni per ogni incantesimo.*

---

## 📖 STRUTTURA NARRATIVA

### Capitoli (ogni 10 livelli)

| Capitolo | Livelli | Ambientazione | Boss/Evento |
|----------|---------|---------------|-------------|
| 1. Il Laboratorio | 1-10 | Cantina alchimista | Tutorial |
| 2. La Serra Magica | 11-20 | Giardino incantato | Pianta carnivora |
| 3. Le Catacombe | 21-30 | Sotterranei bui | Fantasma |
| 4. La Torre | 31-40 | Torre del mago | Gargoyle |
| 5. Il Cielo | 41-50 | Nuvole + arcobaleno | Drago finale |

### Cutscene tra Capitoli

```swift
struct StoryCutscene: Identifiable {
    let id: Int
    let chapter: Int
    let title: String
    let dialogues: [Dialogue]
    let backgroundImage: String
    let unlocksAt: Int // Livello
}

struct Dialogue {
    let character: Character
    let text: String
    let emotion: Emotion
    
    enum Character {
        case lumi
        case master
        case villain
        case narrator
    }
    
    enum Emotion {
        case happy, sad, surprised, determined, scared
    }
}

// Esempio dialoghi
let chapter1Intro = StoryCutscene(
    id: 1,
    chapter: 1,
    title: "L'Inizio dell'Avventura",
    dialogues: [
        Dialogue(character: .narrator, text: "Nel piccolo villaggio di Alchemis...", emotion: .happy),
        Dialogue(character: .lumi, text: "Maestro! Cosa è successo?!", emotion: .scared),
        Dialogue(character: .master, text: "La maledizione... le pozioni... devi ordinarle...", emotion: .sad),
        Dialogue(character: .lumi, text: "Non ti preoccupare! Ce la farò!", emotion: .determined)
    ],
    backgroundImage: "story_lab_intro",
    unlocksAt: 1
)
```

---

## 👤 SISTEMA PERSONAGGIO

### Lumi - Il Protagonista

```swift
struct PlayerCharacter: Codable {
    var name: String = "Lumi"
    var level: Int = 1
    var experience: Int = 0
    var outfit: Outfit = .basic
    var hat: Hat = .apprentice
    var pet: Pet? = nil
    var title: Title = .apprentice
    
    enum Outfit: String, CaseIterable, Codable {
        case basic = "Apprendista"
        case forest = "Guardiano della Foresta"
        case dark = "Alchimista Oscuro"
        case royal = "Alchimista Reale"
        case rainbow = "Maestro dei Colori"
    }
    
    enum Hat: String, CaseIterable, Codable {
        case apprentice = "Cappello Apprendista"
        case wizard = "Cappello da Mago"
        case crown = "Corona Dorata"
        case witch = "Cappello da Strega"
        case chef = "Cappello da Chef"
    }
    
    enum Pet: String, CaseIterable, Codable {
        case cat = "Gatto Magico"
        case owl = "Gufo Saggio"
        case dragon = "Baby Drago"
        case slime = "Slime Colorato"
        case phoenix = "Fenice"
    }
    
    enum Title: String, CaseIterable, Codable {
        case apprentice = "Apprendista"
        case student = "Studente"
        case alchemist = "Alchimista"
        case master = "Maestro"
        case grandmaster = "Gran Maestro"
        case legend = "Leggenda"
    }
    
    var experienceToNextLevel: Int {
        level * 100
    }
    
    mutating func addExperience(_ amount: Int) {
        experience += amount
        while experience >= experienceToNextLevel {
            experience -= experienceToNextLevel
            level += 1
            // Unlock rewards
        }
    }
}
```

### Avatar View

```swift
struct CharacterAvatarView: View {
    let character: PlayerCharacter
    let size: CGFloat
    var showPet: Bool = true
    
    var body: some View {
        ZStack {
            // Corpo
            CharacterBodyView(outfit: character.outfit, size: size)
            
            // Cappello
            CharacterHatView(hat: character.hat, size: size)
                .offset(y: -size * 0.3)
            
            // Pet (se presente)
            if showPet, let pet = character.pet {
                PetView(pet: pet, size: size * 0.3)
                    .offset(x: size * 0.4, y: size * 0.2)
            }
        }
    }
}

struct CharacterBodyView: View {
    let outfit: PlayerCharacter.Outfit
    let size: CGFloat
    
    var outfitColor: Color {
        switch outfit {
        case .basic: return Color(hex: "6366F1")
        case .forest: return Color(hex: "22C55E")
        case .dark: return Color(hex: "6B21A8")
        case .royal: return Color(hex: "EAB308")
        case .rainbow: return Color(hex: "EC4899")
        }
    }
    
    var body: some View {
        ZStack {
            // Corpo semplice (stile cartoon/chibi)
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [outfitColor, outfitColor.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size * 0.6, height: size * 0.8)
            
            // Faccia
            Circle()
                .fill(Color(hex: "FFDBB4")) // Skin tone
                .frame(width: size * 0.5, height: size * 0.5)
                .offset(y: -size * 0.15)
            
            // Occhi
            HStack(spacing: size * 0.1) {
                Circle()
                    .fill(Color.black)
                    .frame(width: size * 0.08, height: size * 0.08)
                Circle()
                    .fill(Color.black)
                    .frame(width: size * 0.08, height: size * 0.08)
            }
            .offset(y: -size * 0.18)
            
            // Sorriso
            Path { path in
                path.addArc(
                    center: CGPoint(x: size * 0.3, y: size * 0.3),
                    radius: size * 0.08,
                    startAngle: .degrees(0),
                    endAngle: .degrees(180),
                    clockwise: false
                )
            }
            .stroke(Color.black, lineWidth: 2)
            .offset(y: -size * 0.08)
        }
    }
}
```

---

## 🎬 CUTSCENE VIEW

```swift
struct CutsceneView: View {
    let cutscene: StoryCutscene
    let onComplete: () -> Void
    
    @State private var currentDialogueIndex = 0
    @State private var displayedText = ""
    @State private var isTyping = false
    
    var currentDialogue: Dialogue {
        cutscene.dialogues[currentDialogueIndex]
    }
    
    var body: some View {
        ZStack {
            // Background
            Image(cutscene.backgroundImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(Color.black.opacity(0.3))
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Character speaking
                HStack(alignment: .bottom, spacing: 20) {
                    // Avatar
                    CharacterSpeakerView(character: currentDialogue.character)
                        .frame(width: 80, height: 100)
                    
                    // Dialogue box
                    VStack(alignment: .leading, spacing: 10) {
                        Text(characterName(currentDialogue.character))
                            .font(.headline)
                            .foregroundColor(.yellow)
                        
                        Text(displayedText)
                            .font(.body)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.yellow.opacity(0.5), lineWidth: 2)
                            )
                    )
                }
                .padding()
                
                // Tap to continue
                if !isTyping {
                    Text("Tocca per continuare...")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.bottom)
                }
            }
        }
        .onTapGesture {
            if isTyping {
                // Skip typing animation
                displayedText = currentDialogue.text
                isTyping = false
            } else if currentDialogueIndex < cutscene.dialogues.count - 1 {
                // Next dialogue
                currentDialogueIndex += 1
                startTyping()
            } else {
                // Cutscene complete
                onComplete()
            }
        }
        .onAppear {
            startTyping()
        }
    }
    
    private func startTyping() {
        displayedText = ""
        isTyping = true
        
        let text = currentDialogue.text
        var charIndex = 0
        
        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            if charIndex < text.count {
                let index = text.index(text.startIndex, offsetBy: charIndex)
                displayedText += String(text[index])
                charIndex += 1
            } else {
                timer.invalidate()
                isTyping = false
            }
        }
    }
    
    private func characterName(_ character: Dialogue.Character) -> String {
        switch character {
        case .lumi: return "Lumi"
        case .master: return "Maestro"
        case .villain: return "???"
        case .narrator: return ""
        }
    }
}
```

---

## 🏠 CUSTOMIZATION MENU

```swift
struct CharacterCustomizationView: View {
    @ObservedObject var characterManager: CharacterManager
    @State private var selectedTab: CustomizationTab = .outfit
    
    enum CustomizationTab {
        case outfit, hat, pet, title
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Preview
            CharacterAvatarView(character: characterManager.character, size: 150)
                .padding()
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.1))
                )
            
            // Name
            Text(characterManager.character.name)
                .font(.title.bold())
            
            Text(characterManager.character.title.rawValue)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Tab selector
            Picker("Categoria", selection: $selectedTab) {
                Text("Vestito").tag(CustomizationTab.outfit)
                Text("Cappello").tag(CustomizationTab.hat)
                Text("Pet").tag(CustomizationTab.pet)
                Text("Titolo").tag(CustomizationTab.title)
            }
            .pickerStyle(.segmented)
            
            // Items grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 15) {
                    ForEach(itemsForTab, id: \.self) { item in
                        CustomizationItemView(
                            item: item,
                            isSelected: isSelected(item),
                            isUnlocked: isUnlocked(item),
                            onSelect: { select(item) }
                        )
                    }
                }
            }
        }
        .padding()
    }
}

struct CustomizationItemView: View {
    let item: String
    let isSelected: Bool
    let isUnlocked: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack {
                // Item preview
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue : Color.white.opacity(0.1))
                    .frame(width: 70, height: 70)
                    .overlay(
                        Group {
                            if isUnlocked {
                                // Item image
                                Text("🎩") // Placeholder
                                    .font(.system(size: 30))
                            } else {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                    )
                
                Text(item)
                    .font(.caption)
                    .lineLimit(1)
            }
        }
        .disabled(!isUnlocked)
        .opacity(isUnlocked ? 1 : 0.5)
    }
}
```

---

## 📊 PROGRESSIONE E REWARD

```swift
struct RewardSystem {
    // Ricompense per livelli del personaggio
    static let levelRewards: [Int: [Reward]] = [
        5: [.outfit(.forest)],
        10: [.hat(.wizard), .powerUp(.magicWand, 5)],
        15: [.pet(.cat)],
        20: [.outfit(.dark), .title(.student)],
        25: [.hat(.crown)],
        30: [.pet(.owl), .title(.alchemist)],
        35: [.outfit(.royal)],
        40: [.pet(.dragon), .title(.master)],
        45: [.hat(.chef)],
        50: [.outfit(.rainbow), .pet(.phoenix), .title(.grandmaster)]
    ]
    
    enum Reward {
        case outfit(PlayerCharacter.Outfit)
        case hat(PlayerCharacter.Hat)
        case pet(PlayerCharacter.Pet)
        case title(PlayerCharacter.Title)
        case powerUp(PowerUpType, Int)
        case coins(Int)
    }
}

struct LevelUpView: View {
    let newLevel: Int
    let rewards: [RewardSystem.Reward]
    let onContinue: () -> Void
    
    @State private var showRewards = false
    
    var body: some View {
        ZStack {
            // Confetti background
            ConfettiView()
            
            VStack(spacing: 30) {
                // Level up text
                Text("LEVEL UP!")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                // New level
                Text("Livello \(newLevel)")
                    .font(.title)
                
                // Rewards
                if showRewards && !rewards.isEmpty {
                    VStack(spacing: 15) {
                        Text("Hai sbloccato:")
                            .font(.headline)
                        
                        ForEach(rewards.indices, id: \.self) { index in
                            RewardItemView(reward: rewards[index])
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
                
                // Continue button
                Button(action: onContinue) {
                    Text("CONTINUA")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(16)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring()) {
                    showRewards = true
                }
            }
        }
    }
}
```

---

## 🗃️ PERSISTENZA

```swift
class CharacterManager: ObservableObject {
    static let shared = CharacterManager()
    
    @Published var character: PlayerCharacter
    @Published var unlockedOutfits: Set<PlayerCharacter.Outfit>
    @Published var unlockedHats: Set<PlayerCharacter.Hat>
    @Published var unlockedPets: Set<PlayerCharacter.Pet>
    @Published var unlockedTitles: Set<PlayerCharacter.Title>
    @Published var watchedCutscenes: Set<Int>
    
    private let defaults = UserDefaults.standard
    
    init() {
        // Load from UserDefaults
        // ...
    }
    
    func save() {
        // Save to UserDefaults
        // ...
    }
    
    func hasCutsceneToShow(forLevel level: Int) -> StoryCutscene? {
        // Check if there's an unwatched cutscene for this level
        // ...
    }
    
    func markCutsceneAsWatched(_ cutscene: StoryCutscene) {
        watchedCutscenes.insert(cutscene.id)
        save()
    }
}
```

---

## ✅ CHECKLIST IMPLEMENTAZIONE

### Storia
1. [ ] Crea 5 cutscene (1 per capitolo)
2. [ ] Implementa `CutsceneView` con typing effect
3. [ ] Background images per ogni ambientazione
4. [ ] Trigger cutscene automatico al livello giusto
5. [ ] Opzione "Skip" per le cutscene

### Personaggio
6. [ ] Crea `PlayerCharacter` model
7. [ ] Implementa `CharacterAvatarView` modulare
8. [ ] Sistema esperienza/level up
9. [ ] Menu customization
10. [ ] Persistenza character data

### Rewards
11. [ ] Sistema reward per level up
12. [ ] `LevelUpView` con animazioni
13. [ ] Unlock items visualizzato nel menu
14. [ ] Integra XP gain nel gameplay

---

## 🚀 ISTRUZIONI PER CLAUDE CODE

1. Lo stile grafico del personaggio deve essere **carino/chibi** (occhi grandi, corpo piccolo)
2. Le cutscene devono essere **skippabili** ma memorizzabili
3. Il sistema XP si guadagna: +10 per livello completato, +5 per stella, +20 per combo max
4. I rewards sbloccati devono essere **persistenti**
5. Il personaggio appare nel menu principale e durante le cutscene
6. Mantieni tutto leggero - le immagini possono essere placeholder inizialmente
