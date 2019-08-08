import 'package:flutter/material.dart';

import 'package:login_with_amazon/login_with_amazon.dart';

void main() => runApp(MyApp());

/// @nodoc
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

const _scopes = {
  'profile': null,
  'alexa:all': {
    'productID': 'SomeProductId',
    'productInstanceAttributes': {
      'deviceSerialNumber': 'serialNumberHere',
    },
  },
  'dash:replenish': {
    'device_model': 'SomeDeviceModel',
    'serial': 'serialNumberHere',
    'is_test_device': true
  },
};

/// @nodoc
class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  List<Widget> _authRespose = [];
  String _accessToken = '';
  String _logResult = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              RaisedButton(
                onPressed: () async {
                  try {
                    final result = await LoginWithAmazon.login(_scopes);
                    setState(() {
                      _logResult = result.containsKey("accessToken")
                          ? "Logged In"
                          : "Cancelled";
                      _authRespose = result.entries.map((entry) {
                        return Text("${entry.key}: ${entry.value}");
                      }).toList();
                    });
                  } catch (e) {
                    setState(() {
                      _logResult = "Cancelled";
                    });
                  }
                },
                child: Text("Login"),
              ),
              RaisedButton(
                onPressed: () async {
                  final result = await LoginWithAmazon.getAccessToken(_scopes);
                  setState(() {
                    _accessToken = result;
                  });
                },
                child: Text("Get Access Token"),
              ),
              RaisedButton(
                onPressed: () async {
                  await LoginWithAmazon.logout();
                  setState(() {
                    _logResult = 'Logged Out';
                  });
                },
                child: Text("Logout"),
              ),
              Text('LogResult: $_logResult'),
              Text('AccessToken: $_accessToken'),
              ..._authRespose
            ],
          ),
        ),
      ),
    );
  }
}
