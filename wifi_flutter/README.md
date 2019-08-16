# wifi_flutter

A simple plugin that allows network scanning on android.

## Getting Started

Due to iOS limitations, it is impossible to retrieve a list of nearby wifi networks. Unfortunately the same will hold true for android R+. However, for the time being, this simple plugin will return a list of wifi networks.

```
import 'package:wifi_flutter/wifi_flutter.dart';

final networks = WifiFlutter.wifiNetworks;
```

networks is a list of `WifiNetwork` each wifiNetwork object contains the SSID, RSSI (signal strength), and a boolean flag indicating if the network is secure.
