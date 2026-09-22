# Sezione Info & Legal - Impostazioni Sphera

```swift
// Info & Legal
SettingsSection(title: L10n.info) {
    // Versione
    HStack {
        Image(systemName: "info.circle.fill")
            .foregroundColor(.ballBlue)
        Text(L10n.version)
            .foregroundColor(.white.opacity(0.7))
        Spacer()
        Text("1.0.4")
            .foregroundColor(.white.opacity(0.5))
    }
    .padding()

    Divider()
        .background(Color.white.opacity(0.1))

    // Support Link
    Link(destination: URL(string: "https://saimonapps.github.io/Saimon_Apps/#support")!) {
        HStack {
            Image(systemName: "questionmark.circle.fill")
                .foregroundColor(.ballGreen)
            Text("Support")
                .foregroundColor(.white.opacity(0.9))
            Spacer()
            Image(systemName: "arrow.up.right.square")
                .font(.caption)
                .foregroundColor(.white.opacity(0.4))
        }
        .padding()
    }

    Divider()
        .background(Color.white.opacity(0.1))

    // Privacy Policy Link
    Link(destination: URL(string: "https://saimonapps.github.io/Saimon_Apps/#privacy")!) {
        HStack {
            Image(systemName: "hand.raised.fill")
                .foregroundColor(.ballPurple)
            Text("Privacy Policy")
                .foregroundColor(.white.opacity(0.9))
            Spacer()
            Image(systemName: "arrow.up.right.square")
                .font(.caption)
                .foregroundColor(.white.opacity(0.4))
        }
        .padding()
    }
}

// Copyright Footer
VStack(spacing: 6) {
    Text("© 2026 S@imon Apps")
        .font(.system(size: 13, weight: .semibold, design: .rounded))
        .foregroundStyle(
            LinearGradient(
                colors: [
                    Color(hex: "A855F7"),
                    Color(hex: "EC4899"),
                    Color(hex: "3B82F6")
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )

    Text("All rights reserved.")
        .font(.system(size: 11, weight: .regular))
        .foregroundColor(.white.opacity(0.35))
}
.frame(maxWidth: .infinity)
.padding(.top, 20)
.padding(.bottom, 12)
```
