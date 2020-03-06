import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    'productID': 'YOURPRODUCTID',
    'productInstanceAttributes': {
      'deviceSerialNumber': 'serialNumberHere',
    },
  },
  'dash:replenish': {
    'device_model': 'YOURDEVICEMODEL',
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
  String _logResult = '';
  String _result = '';
  String _codeChallengeMethod = 'plain';
  final _alexaId = TextEditingController(text: 'YOURPRODUCTID');
  final _dashModel = TextEditingController(text: 'YOURDEVICEMODEL');
  final _serialNumber = TextEditingController(text: 'someSerialNeeded');
  final _codeChallenge = TextEditingController(
      text: 'code_generated_by_the_dash_device_for_LWA_verification');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _alexaId,
                decoration: InputDecoration(
                  labelText: 'Alexa Product Id',
                ),
              ),
              TextFormField(
                controller: _dashModel,
                decoration: InputDecoration(
                  labelText: 'Dash Model',
                ),
              ),
              TextFormField(
                controller: _serialNumber,
                decoration: InputDecoration(
                  labelText: 'Serial Number',
                ),
              ),
              TextFormField(
                controller: _codeChallenge,
                decoration: InputDecoration(
                  labelText: 'Code Challenge',
                ),
              ),
              DropdownButtonFormField(
                  onChanged: (val) {
                    setState(() {
                      _codeChallengeMethod = val;
                    });
                  },
                  value: _codeChallengeMethod,
                  items: ['plain', 'S256']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList()),
              RaisedButton(
                onPressed: () async {
                  try {
                    final result = await LoginWithAmazon.login({
                      'profile': null,
                    });
                    _result = result.entries
                        .map((entry) => "${entry.key}: ${entry.value}")
                        .reduce((str, str2) => "$str, \n $str2");
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
                      _logResult = "failed";
                    });
                  }
                },
                child: Text("Login"),
              ),
              RaisedButton(
                onPressed: () async {
                  try{
                    final result = await LoginWithAmazon.getAuthCode(
                      _codeChallenge.text,
                      "plain",
                      {
                        'profile': null,
                        'dash:replenish': {
                          'device_model': _dashModel.text,
                          'serial': _serialNumber.text,
                          'is_test_device': true
                        },
                      },
                    );
                    _result = result.entries
                        .map((entry) => "${entry.key}: ${entry.value}")
                        .reduce((str, str2) => "$str, \n $str2");
                    setState(() {
                      _authRespose = result.entries.map((entry) {
                        return Text("${entry.key}: ${entry.value}");
                      }).toList();
                    });
                  }catch (e){
                    setState(() {
                      _authRespose = [Text("failed")];
                    });
                  }
                },
                child: Text("Get Dash Auth Code"),
              ),
              RaisedButton(
                onPressed: () async {
                  final result = await LoginWithAmazon.getAuthCode(
                    "code_generated_by_the_dash_device_for_LWA_verification",
                    "plain",
                    {
                      'profile': null,
                      'alexa:all': {
                        'productID': _alexaId.text,
                        'productInstanceAttributes': {
                          'deviceSerialNumber': _serialNumber.text,
                        },
                      }
                    },
                  );
                  _result = result.entries
                      .map((entry) => "${entry.key}: ${entry.value}")
                      .reduce((str, str2) => "$str, \n $str2");
                  setState(() {
                    _authRespose = result.entries.map((entry) {
                      return Text("${entry.key}: ${entry.value}");
                    }).toList();
                  });
                },
                child: Text("Get Alexa Auth Code"),
              ),
              RaisedButton(
                onPressed: () async {
                  final result = await LoginWithAmazon.getAccessToken(_scopes);
                  setState(() {
                    _authRespose = [Text('AccessToken: $result')];
                    _result = result;
                  });
                },
                child: Text("Get Access Token"),
              ),
              RaisedButton(
                onPressed: () async {
                  await LoginWithAmazon.logout();
                  setState(() {
                    _logResult = 'Logged Out';
                    _result = '';
                  });
                },
                child: Text("Logout"),
              ),
              Text('LogResult: $_logResult'),
              ..._authRespose,
              RaisedButton(
                onPressed: () async {
                  Clipboard.setData(ClipboardData(text: _result));
                },
                child: Text("Copy To Clipboard"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
