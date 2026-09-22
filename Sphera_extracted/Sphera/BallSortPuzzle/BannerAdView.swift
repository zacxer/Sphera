//
//  BannerAdView.swift
//  BallSortPuzzle
//
//  Created on 2026-01-03.
//  Updated on 2026-01-04 - Full AdMob Integration (SDK 12.x)
//

import SwiftUI
import GoogleMobileAds

// MARK: - Banner Ad View

struct BannerAdView: View {
    var body: some View {
        BannerAdRepresentable()
            .frame(width: 320, height: 50)
    }
}

struct BannerAdRepresentable: UIViewRepresentable {

    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView()
        bannerView.adUnitID = AdManager.shared.getBannerAdUnitID()

        // Imposta dimensione fissa standard (320x50)
        bannerView.adSize = AdSizeBanner

        // Get the root view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            bannerView.rootViewController = rootVC
        }

        bannerView.load(Request())
        return bannerView
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black
            .ignoresSafeArea()

        VStack {
            Spacer()
            BannerAdView()
        }
    }
}
