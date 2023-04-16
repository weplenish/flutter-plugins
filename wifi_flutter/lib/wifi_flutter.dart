import 'dart:async';

import 'package:flutter/services.dart';

import 'wifi_network.dart';
export 'wifi_network.dart';

/// A plugin to retrieve a list of wifi networks
class WifiFlutter {
  static const MethodChannel _channel = const MethodChannel('wifi_flutter');

  /// prompts the user for permissions if they aren't already available.
  /// returns true if a prompt was shown, false if they already have permissions
  static Future promptPermissions() =>
      _channel.invokeMethod('promptPermissions');

  /// returns the results of the most recent wifi scan
  /// it is unecessary to run a scan
  static Future<Iterable<WifiNetwork>?> get wifiNetworks async {
    final networks = await _channel.invokeMethod<List<dynamic>>('getNetworks');
    return networks?.map<WifiNetwork>((network) => WifiNetwork.fromMap(network));
  }

  /// triggers a network scan
  static Future<Iterable<WifiNetwork>?> scanNetworks() async {
    final networks = await _channel.invokeMethod<List<dynamic>>('scanNetworks');
    return networks?.map<WifiNetwork>((network) => WifiNetwork.fromMap(network));
  }
}
