/// Information about a wifi network
class WifiNetwork {
  /// Network Name
  final String ssid;

  /// Network strength / level
  final int rssi;

  /// is the network protected
  final bool isSecure;

  const WifiNetwork(this.ssid, this.rssi, this.isSecure);

  /// converts map to a dart class
  factory WifiNetwork.fromMap(Map<dynamic, dynamic> map) =>
      WifiNetwork(map['ssid'], map['rssi'], map['isSecure']);
}
