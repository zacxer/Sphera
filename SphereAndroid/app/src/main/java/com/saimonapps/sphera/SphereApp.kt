package com.saimonapps.sphera

import android.app.Application
import com.google.android.gms.ads.MobileAds

class SphereApp : Application() {
    override fun onCreate() {
        super.onCreate()
        MobileAds.initialize(this)
    }
}
