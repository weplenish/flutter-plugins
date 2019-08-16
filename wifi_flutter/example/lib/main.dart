import 'package:flutter/material.dart';
import 'package:wifi_flutter/wifi_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Iterable<WifiNetwork> _platformVersion = [];

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
          child: Text('Running on: $_platformVersion\n'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final networks = await WifiFlutter.wifiNetworks;
            setState(() {
              _platformVersion = networks;
            });
          },
        ),
      ),
    );
  }
}
