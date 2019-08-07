import 'package:flutter/material.dart';

import 'package:login_with_amazon/login_with_amazon.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

const _scopes = {
  'profile': null,
  'alexa:all': {
    'productID': 'JAVA',
    'productInstanceAttributes': {
      'deviceSerialNumber': 'serialNumberHere',
    },
  },
  'dash:replenish': {
    'device_model': 'WP230B-A',
    'serial': 'serialNumberHere',
    'is_test_device': true
  },
};

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  List<Widget> authRespose = [];
  String accessToken = '';
  String logResult = '';

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
                      logResult = result.containsKey("accessToken")
                          ? "Logged In"
                          : "Cancelled";
                      authRespose = result.entries.map((entry) {
                        return Text("${entry.key}: ${entry.value}");
                      }).toList();
                    });
                  } catch (e) {
                    setState(() {
                      logResult = "Cancelled";
                    });
                  }
                },
                child: Text("Login"),
              ),
              RaisedButton(
                onPressed: () async {
                  final result = await LoginWithAmazon.getAccessToken(_scopes);
                  setState(() {
                    accessToken = result;
                  });
                },
                child: Text("Get Access Token"),
              ),
              RaisedButton(
                onPressed: () async {
                  await LoginWithAmazon.logout();
                  setState(() {
                    logResult = 'Logged Out';
                  });
                },
                child: Text("Logout"),
              ),
              Text('LogResult: $logResult'),
              Text('AccessToken: $accessToken'),
              ...authRespose
            ],
          ),
        ),
      ),
    );
  }
}
