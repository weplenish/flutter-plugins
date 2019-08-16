package com.weplenish.wifi_flutter

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.wifi.ScanResult
import android.net.wifi.WifiManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

private val wifiSecurities = setOf("WEP", "WPA", "WPA2", "WPA_EAP", "IEEE8021X")

class WifiFlutterPlugin(private val context: Context): MethodCallHandler {
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "wifi_flutter")
      channel.setMethodCallHandler(WifiFlutterPlugin(registrar.activity().applicationContext))
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when(call.method){
      "getNetworks" -> {
        val wifiManager = context.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        result.success(mapScanResults(wifiManager.scanResults))
      }
      "scanNetworks" -> startWifiScan(result)
      else -> result.notImplemented()
    }
  }

  private fun startWifiScan(result: Result){
    IntentFilter().run {
      addAction(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION)
      context.applicationContext.registerReceiver(WifiScanReceiver(result), this)
    }

    val wifiManager = context.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
    val scanStarted = wifiManager.startScan()
    if(!scanStarted){
      result.error("startScan", "Unable to start scan.", scanStarted)
    }
  }
}

private fun mapScanResults(results: List<ScanResult>) = results.map { network ->
  mapOf(
    "ssid" to network.SSID,
    "rssi" to network.level,
    "isSecure" to wifiSecurities.any { sec -> network.capabilities.contains(sec) }
  )
}

private class WifiScanReceiver(private val result: Result) : BroadcastReceiver() {
  override fun onReceive(context: Context, intent: Intent) {
    if (intent.action == WifiManager.SCAN_RESULTS_AVAILABLE_ACTION) {
      val wifiManager = context.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
      result.success(mapScanResults(wifiManager.scanResults))
      context.applicationContext.unregisterReceiver(this)
    }
  }
}