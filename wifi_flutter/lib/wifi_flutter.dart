import 'dart:async';

import 'package:flutter/services.dart';

import 'wifi_network.dart';
export 'wifi_network.dart';

class WifiFlutter {
  static const MethodChannel _channel = const MethodChannel('wifi_flutter');

  static Future<Iterable<WifiNetwork>> get wifiNetworks async {
    final networks = await _channel.invokeListMethod('getNetworks');
    return networks.map((network) => WifiNetwork.fromMap(network));
  }

  static Future<Iterable<WifiNetwork>> get scanNetworks async {
    final networks = await _channel.invokeListMethod('scanNetworks');
    return networks.map((network) => WifiNetwork.fromMap(network));
  }
}
