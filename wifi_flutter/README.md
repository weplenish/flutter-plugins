# wifi_flutter

A simple plugin that allows network scanning on android.

## Getting Started

In your pubspec add the dependency
`wifi_flutter: ^0.1.0+1`

Due to iOS limitations, it is impossible to retrieve a list of nearby wifi networks. Unfortunately the same will hold true for android R+. However, for the time being, this simple plugin will return a list of wifi networks on android.

networks is a list of `WifiNetwork` each wifiNetwork object contains the SSID, RSSI (signal strength), and a boolean flag indicating if the network is secure.

#### Import

`import 'package:wifi_flutter/wifi_flutter.dart';`

#### Commands

`final networks = WifiFlutter.wifiNetworks;`

Retrieves the most recent wifi networks. The scan is done periodically by android so this list shouldn't be terribly out of date.

`final networks = WifiFlutter.scanNetworks();`
 
 Attempts a network scan and retrieves a list of the results of that scan.

 `final prompted = WifiFlutter.promptPermissions();`

 If the required permissions are not accessible, this will prompt the user for them. It returns true if it made a prompt (the permissions weren't available) or false if it didn't make a prompt (the permissions were available and the code that requires the permissions can be run).