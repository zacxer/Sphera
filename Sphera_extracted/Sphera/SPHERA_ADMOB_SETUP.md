# Sphera - AdMob Integration Instructions for Claude Code

## Project Info
- **App Name**: Sphera (Ball Sort Puzzle)
- **Bundle ID**: com.sphera.puzzlegame
- **Target**: iOS 17+
- **SDK**: Google Mobile Ads SDK (già installato via SPM)

---

## AdMob IDs (PRODUCTION - REAL)

```swift
// App ID (per Info.plist)
let appID = "ca-app-pub-2053215380495624~3249339587"

// Ad Unit IDs (per AdManager.swift)
let bannerAdUnitID = "ca-app-pub-2053215380495624/2922886589"
let interstitialAdUnitID = "ca-app-pub-2053215380495624/9930298005"
let rewardedAdUnitID = "ca-app-pub-2053215380495624/1832316132"
```

---

## TASK 1: Aggiorna Info.plist

Aggiungi/aggiorna queste chiavi nel file `Info.plist`:

```xml
<!-- AdMob App ID - OBBLIGATORIO -->
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-2053215380495624~3249339587</string>

<!-- App Tracking Transparency - OBBLIGATORIO iOS 14.5+ -->
<key>NSUserTrackingUsageDescription</key>
<string>Questo permesso ci consente di mostrarti annunci più rilevanti per te.</string>

<!-- SKAdNetwork IDs per attribution -->
<key>SKAdNetworkItems</key>
<array>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>cstr6suwn9.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>4fzdc2evr5.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>4pfyvq9l8r.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>2fnua5tdw4.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>ydx93a7ass.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>5a6flpkh64.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>p78aez3asi.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>v72qych5uu.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>ludvb6z3bs.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>cp8zw746q7.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>3sh42y64q3.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>c6k4g5qg8m.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>s39g8k73mm.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>3rd42ekr43.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>22mmun2rn5.skadnetwork</string>
    </dict>
</array>
```

---

## TASK 2: Crea/Aggiorna AdManager.swift

Crea o aggiorna il file `AdManager.swift` con supporto completo per Banner, Interstitial e Rewarded:

```swift
import Foundation
import GoogleMobileAds
import AppTrackingTransparency
import SwiftUI

@MainActor
class AdManager: NSObject, ObservableObject {
    static let shared = AdManager()
    
    // MARK: - Ad Unit IDs
    #if DEBUG
    // Test IDs (per sviluppo)
    private let bannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"
    private let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910"
    private let rewardedAdUnitID = "ca-app-pub-3940256099942544/1712485313"
    #else
    // Production IDs (REALI)
    private let bannerAdUnitID = "ca-app-pub-2053215380495624/2922886589"
    private let interstitialAdUnitID = "ca-app-pub-2053215380495624/9930298005"
    private let rewardedAdUnitID = "ca-app-pub-2053215380495624/1832316132"
    #endif
    
    // MARK: - Published Properties
    @Published var isInterstitialReady = false
    @Published var isRewardedReady = false
    
    // MARK: - Private Properties
    private var interstitialAd: GADInterstitialAd?
    private var rewardedAd: GADRewardedAd?
    private var rewardCompletion: ((Bool) -> Void)?
    
    // MARK: - Initialization
    override init() {
        super.init()
    }
    
    func initialize() {
        GADMobileAds.sharedInstance().start { [weak self] status in
            print("✅ AdMob SDK initialized")
            print("📊 Adapters: \(status.adapterStatusesByClassName)")
            
            Task { @MainActor in
                self?.loadInterstitialAd()
                self?.loadRewardedAd()
            }
        }
    }
    
    // MARK: - ATT Permission
    func requestTrackingPermission() {
        if #available(iOS 14, *) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    switch status {
                    case .authorized:
                        print("✅ Tracking authorized")
                    case .denied:
                        print("❌ Tracking denied")
                    case .notDetermined:
                        print("⏳ Tracking not determined")
                    case .restricted:
                        print("🚫 Tracking restricted")
                    @unknown default:
                        break
                    }
                }
            }
        }
    }
    
    // MARK: - Banner Ad Unit ID Getter
    func getBannerAdUnitID() -> String {
        return bannerAdUnitID
    }
    
    // MARK: - Interstitial Ads
    func loadInterstitialAd() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: interstitialAdUnitID, request: request) { [weak self] ad, error in
            if let error = error {
                print("❌ Failed to load interstitial: \(error.localizedDescription)")
                self?.isInterstitialReady = false
                return
            }
            print("✅ Interstitial ad loaded")
            self?.interstitialAd = ad
            self?.interstitialAd?.fullScreenContentDelegate = self
            self?.isInterstitialReady = true
        }
    }
    
    func showInterstitialAd() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            print("❌ No root view controller")
            return
        }
        
        // Find the topmost presented controller
        var topController = rootVC
        while let presented = topController.presentedViewController {
            topController = presented
        }
        
        if let ad = interstitialAd {
            ad.present(fromRootViewController: topController)
        } else {
            print("❌ Interstitial not ready")
            loadInterstitialAd()
        }
    }
    
    // MARK: - Rewarded Ads
    func loadRewardedAd() {
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID: rewardedAdUnitID, request: request) { [weak self] ad, error in
            if let error = error {
                print("❌ Failed to load rewarded: \(error.localizedDescription)")
                self?.isRewardedReady = false
                return
            }
            print("✅ Rewarded ad loaded")
            self?.rewardedAd = ad
            self?.rewardedAd?.fullScreenContentDelegate = self
            self?.isRewardedReady = true
        }
    }
    
    func showRewardedAd(completion: @escaping (Bool) -> Void) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            print("❌ No root view controller")
            completion(false)
            return
        }
        
        // Find the topmost presented controller
        var topController = rootVC
        while let presented = topController.presentedViewController {
            topController = presented
        }
        
        guard let ad = rewardedAd else {
            print("❌ Rewarded ad not ready")
            completion(false)
            loadRewardedAd()
            return
        }
        
        rewardCompletion = completion
        
        ad.present(fromRootViewController: topController) { [weak self] in
            let reward = ad.adReward
            print("🎁 User earned reward: \(reward.amount) \(reward.type)")
            self?.rewardCompletion?(true)
            self?.rewardCompletion = nil
        }
    }
}

// MARK: - GADFullScreenContentDelegate
extension AdManager: GADFullScreenContentDelegate {
    
    nonisolated func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        Task { @MainActor in
            print("📺 Ad dismissed")
            if ad is GADInterstitialAd {
                isInterstitialReady = false
                loadInterstitialAd()
            } else if ad is GADRewardedAd {
                isRewardedReady = false
                loadRewardedAd()
            }
        }
    }
    
    nonisolated func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        Task { @MainActor in
            print("❌ Ad failed to present: \(error.localizedDescription)")
            if ad is GADInterstitialAd {
                isInterstitialReady = false
                loadInterstitialAd()
            } else if ad is GADRewardedAd {
                isRewardedReady = false
                rewardCompletion?(false)
                rewardCompletion = nil
                loadRewardedAd()
            }
        }
    }
    
    nonisolated func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("📺 Ad will present")
    }
}
```

---

## TASK 3: Crea BannerAdView.swift

```swift
import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    let adUnitID: String
    
    init() {
        self.adUnitID = AdManager.shared.getBannerAdUnitID()
    }
    
    func makeUIView(context: Context) -> GADBannerView {
        let bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = adUnitID
        
        // Get the root view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            bannerView.rootViewController = rootVC
        }
        
        bannerView.load(GADRequest())
        return bannerView
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) {}
}

// MARK: - Preview
#Preview {
    BannerAdView()
        .frame(height: 50)
}
```

---

## TASK 4: Crea PrivacyInfo.xcprivacy

Crea questo file nella root del progetto Xcode:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPrivacyTracking</key>
    <true/>
    <key>NSPrivacyTrackingDomains</key>
    <array>
        <string>googleads.g.doubleclick.net</string>
        <string>pagead2.googlesyndication.com</string>
    </array>
    <key>NSPrivacyCollectedDataTypes</key>
    <array>
        <dict>
            <key>NSPrivacyCollectedDataType</key>
            <string>NSPrivacyCollectedDataTypeDeviceID</string>
            <key>NSPrivacyCollectedDataTypeLinked</key>
            <false/>
            <key>NSPrivacyCollectedDataTypeTracking</key>
            <true/>
            <key>NSPrivacyCollectedDataTypePurposes</key>
            <array>
                <string>NSPrivacyCollectedDataTypePurposeThirdPartyAdvertising</string>
            </array>
        </dict>
    </array>
    <key>NSPrivacyAccessedAPITypes</key>
    <array>
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>CA92.1</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

---

## TASK 5: Aggiorna App Entry Point (SpheraApp.swift o simile)

```swift
import SwiftUI
import GoogleMobileAds

@main
struct SpheraApp: App {
    
    init() {
        // Initialize AdMob SDK
        AdManager.shared.initialize()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Request tracking permission
                    AdManager.shared.requestTrackingPermission()
                }
        }
    }
}
```

---

## TASK 6: Esempio di utilizzo nelle View

### Banner (in fondo allo schermo):
```swift
VStack {
    // Game content
    GameView()
    
    // Banner ad at bottom
    BannerAdView()
        .frame(height: 50)
}
```

### Interstitial (dopo completamento livello):
```swift
func onLevelComplete() {
    // Show interstitial every 3 levels
    if currentLevel % 3 == 0 {
        AdManager.shared.showInterstitialAd()
    }
}
```

### Rewarded (per guadagnare coins):
```swift
Button("Watch Ad for +25 Coins") {
    AdManager.shared.showRewardedAd { success in
        if success {
            coins += 25
        }
    }
}
.disabled(!AdManager.shared.isRewardedReady)
```

---

## Checklist Finale

- [ ] Info.plist aggiornato con GADApplicationIdentifier
- [ ] Info.plist aggiornato con NSUserTrackingUsageDescription
- [ ] Info.plist aggiornato con SKAdNetworkItems
- [ ] AdManager.swift creato/aggiornato
- [ ] BannerAdView.swift creato
- [ ] PrivacyInfo.xcprivacy creato
- [ ] App entry point aggiornato con init AdMob
- [ ] Banner integrato nelle view appropriate
- [ ] Interstitial chiamato dopo i livelli
- [ ] Rewarded integrato per i coins

---

## Note Importanti

1. **DEBUG vs RELEASE**: Il codice usa `#if DEBUG` per switchare automaticamente tra test IDs e production IDs
2. **Non cliccare mai** sui tuoi annunci reali - Google banna l'account!
3. **TestFlight**: Gli annunci test funzioneranno, quelli reali potrebbero richiedere tempo
4. **Prima pubblicazione**: AdMob potrebbe impiegare 24-48h per iniziare a servire annunci reali

---

## IDs Quick Reference

```
┌─────────────────────────────────────────────────────────────┐
│                    SPHERA - AdMob IDs                        │
├─────────────────────────────────────────────────────────────┤
│  App ID:         ca-app-pub-2053215380495624~3249339587     │
│  Banner:         ca-app-pub-2053215380495624/2922886589     │
│  Interstitial:   ca-app-pub-2053215380495624/9930298005     │
│  Rewarded:       ca-app-pub-2053215380495624/1832316132     │
├─────────────────────────────────────────────────────────────┤
│  Bundle ID:      com.sphera.puzzlegame                       │
└─────────────────────────────────────────────────────────────┘
```
