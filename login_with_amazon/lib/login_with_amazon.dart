import 'dart:async';

import 'package:flutter/services.dart';

class LoginWithAmazon {
  static const MethodChannel _channel =
      const MethodChannel('login_with_amazon');

  static Future<Map> login(Map<String, dynamic> scopes) =>
      _channel.invokeMethod('login', scopes);

  static Future<bool> logout() => _channel.invokeMethod('logout');

  static Future<String> getAccessToken(Map<String, dynamic> scopes) =>
      _channel.invokeMethod('getAccessToken', scopes);
}
