package com.weplenish.wifi_flutter

import android.Manifest
import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.wifi.ScanResult
import android.net.wifi.WifiManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

private val wifiSecurities = setOf("WEP", "WPA", "WPA2", "WPA_EAP", "IEEE8021X")

class WifiFlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {

  private lateinit var channel : MethodChannel
  private lateinit var activity:Activity
  private lateinit var context: Context

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "wifi_flutter")
    channel.setMethodCallHandler(this);
    context = flutterPluginBinding.applicationContext
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onDetachedFromActivity() {}
  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    this.activity = binding.activity
  }
  override fun onDetachedFromActivityForConfigChanges() {}

  override fun onMethodCall(call: MethodCall, result: Result) {
    when(call.method){
      "promptPermissions" -> {
        if (ContextCompat.checkSelfPermission(activity.applicationContext, Manifest.permission.ACCESS_COARSE_LOCATION)
                != PackageManager.PERMISSION_GRANTED) {
          ActivityCompat.requestPermissions(activity,
                  arrayOf(Manifest.permission.ACCESS_COARSE_LOCATION),
                  42)
          result.success(true)
        }
        result.success(false)
      }
      "getNetworks" -> {
        val wifiManager = activity.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        result.success(mapScanResults(wifiManager.scanResults))
      }
      "scanNetworks" -> startWifiScan(result)
      else -> result.notImplemented()
    }
  }

  private fun startWifiScan(result: Result){
    IntentFilter().run {
      addAction(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION)
      activity.applicationContext.registerReceiver(WifiScanReceiver(result), this)
    }

    val wifiManager = activity.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
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