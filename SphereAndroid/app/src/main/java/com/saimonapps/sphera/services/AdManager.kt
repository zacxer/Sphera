package com.saimonapps.sphera.services

import android.app.Activity
import android.content.Context
import com.google.android.gms.ads.*
import com.google.android.gms.ads.interstitial.InterstitialAd
import com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback
import com.google.android.gms.ads.rewarded.RewardedAd
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback

class AdManager private constructor(context: Context) {

    companion object {
        // Production AdMob IDs (iOS publisher ca-app-pub-2053215380495624)
        // Use test IDs until AdMob Android account is created
        const val BANNER_AD_UNIT = "ca-app-pub-3940256099942544/6300978111"       // test
        const val INTERSTITIAL_AD_UNIT = "ca-app-pub-3940256099942544/1033173712" // test
        const val REWARDED_AD_UNIT = "ca-app-pub-3940256099942544/5224354917"     // test

        @Volatile private var instance: AdManager? = null
        fun getInstance(ctx: Context): AdManager =
            instance ?: synchronized(this) {
                instance ?: AdManager(ctx.applicationContext).also { instance = it }
            }
    }

    private val appContext = context.applicationContext
    private var interstitialAd: InterstitialAd? = null
    private var rewardedAd: RewardedAd? = null
    private var levelCount = 0

    fun preloadInterstitial() {
        val req = AdRequest.Builder().build()
        InterstitialAd.load(appContext, INTERSTITIAL_AD_UNIT, req, object : InterstitialAdLoadCallback() {
            override fun onAdLoaded(ad: InterstitialAd) { interstitialAd = ad }
            override fun onAdFailedToLoad(err: LoadAdError) { interstitialAd = null }
        })
    }

    fun preloadRewarded() {
        val req = AdRequest.Builder().build()
        RewardedAd.load(appContext, REWARDED_AD_UNIT, req, object : RewardedAdLoadCallback() {
            override fun onAdLoaded(ad: RewardedAd) { rewardedAd = ad }
            override fun onAdFailedToLoad(err: LoadAdError) { rewardedAd = null }
        })
    }

    fun onLevelCompleted(activity: Activity, onShown: () -> Unit = {}) {
        levelCount++
        if (levelCount % 3 == 0) showInterstitial(activity, onShown)
        else preloadInterstitial()
    }

    private fun showInterstitial(activity: Activity, onShown: () -> Unit) {
        val ad = interstitialAd ?: run { preloadInterstitial(); return }
        ad.fullScreenContentCallback = object : FullScreenContentCallback() {
            override fun onAdDismissedFullScreenContent() { preloadInterstitial(); onShown() }
            override fun onAdFailedToShowFullScreenContent(e: AdError) { preloadInterstitial() }
        }
        ad.show(activity)
        interstitialAd = null
    }

    fun showRewarded(activity: Activity, onRewarded: (Int) -> Unit) {
        val ad = rewardedAd ?: run { preloadRewarded(); return }
        ad.fullScreenContentCallback = object : FullScreenContentCallback() {
            override fun onAdDismissedFullScreenContent() { preloadRewarded() }
        }
        ad.show(activity) { reward -> onRewarded(25) }
        rewardedAd = null
    }
}
