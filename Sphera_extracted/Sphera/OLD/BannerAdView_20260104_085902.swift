//
//  BannerAdView.swift
//  BallSortPuzzle
//
//  Created on 2026-01-03.
//
//  NOTA: Questo e' un placeholder. Per funzionalita complete,
//  aggiungi il Google Mobile Ads SDK e decommentare il codice.
//

import SwiftUI

// MARK: - Banner Ad View (Placeholder)

/// Vista placeholder per il banner AdMob
/// Sostituire con l'implementazione reale dopo aver aggiunto il SDK
struct BannerAdView: View {
    @ObservedObject private var adManager = AdManager.shared

    var body: some View {
        if adManager.showBanner {
            // Placeholder banner - sostituire con GADBannerView
            PlaceholderBannerView()
        }
    }
}

// MARK: - Placeholder Banner

struct PlaceholderBannerView: View {
    var body: some View {
        HStack {
            Image(systemName: "megaphone.fill")
                .foregroundColor(.white.opacity(0.5))

            Text("Banner Pubblicitario")
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(
            LinearGradient(
                colors: [
                    Color.black.opacity(0.3),
                    Color.black.opacity(0.5)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Real Implementation (Uncomment after adding SDK)

/*
import GoogleMobileAds

struct RealBannerAdView: UIViewRepresentable {
    let adUnitID: String

    init() {
        self.adUnitID = AdManager.shared.bannerAdUnitID
    }

    func makeUIView(context: Context) -> GADBannerView {
        let bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = adUnitID

        // Trova il root view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            bannerView.rootViewController = rootVC
        }

        bannerView.load(GADRequest())
        return bannerView
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {
        // Non necessita aggiornamenti
    }
}

// Adaptive Banner (consigliato per layout dinamici)
struct AdaptiveBannerView: UIViewRepresentable {
    @State private var viewWidth: CGFloat = .zero

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            // Calcola la larghezza adattiva
            let frame = uiView.frame.inset(by: uiView.safeAreaInsets)
            let viewWidth = frame.size.width

            // Crea banner con dimensione adattiva
            let adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
            let bannerView = GADBannerView(adSize: adSize)

            bannerView.adUnitID = AdManager.shared.bannerAdUnitID

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                bannerView.rootViewController = rootVC
            }

            // Rimuovi banner esistenti
            uiView.subviews.forEach { $0.removeFromSuperview() }

            // Aggiungi nuovo banner
            uiView.addSubview(bannerView)
            bannerView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                bannerView.bottomAnchor.constraint(equalTo: uiView.bottomAnchor),
                bannerView.centerXAnchor.constraint(equalTo: uiView.centerXAnchor)
            ])

            bannerView.load(GADRequest())
        }
    }
}
*/

// MARK: - Preview

#Preview {
    ZStack {
        Color.backgroundDark
            .ignoresSafeArea()

        VStack {
            Spacer()
            BannerAdView()
        }
    }
}
