class WifiNetwork {
  final String ssid;
  final String rssi;
  final bool isSecure;

  const WifiNetwork(this.ssid, this.rssi, this.isSecure);
  factory WifiNetwork.fromMap(Map<dynamic, dynamic> map) =>
      WifiNetwork(map['ssid'], map['rssi'], map['isSecure']);
}
