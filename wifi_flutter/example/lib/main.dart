import 'package:flutter/material.dart';
import 'package:wifi_flutter/wifi_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Widget> _platformVersion = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: ListView.builder(
            itemBuilder: (context, i) => _platformVersion[i],
            itemCount: _platformVersion.length,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final noPermissions = await WifiFlutter.promptPermissions();
            if (noPermissions) {
              return;
            }
            final networks = await WifiFlutter.wifiNetworks;
            setState(() {
              _platformVersion = networks
                  .map((network) => Text(
                      "Ssid ${network.ssid} - Strength ${network.rssi} - Secure ${network.isSecure}"))
                  .toList();
            });
          },
        ),
      ),
    );
  }
}
