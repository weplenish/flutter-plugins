import 'dart:async';

import 'package:flutter/services.dart';

/// Flutter LWA plugin to handle platform specific implementations
class LoginWithAmazon {
  /// Channel for speaking to the platforms
  static const MethodChannel _channel =
      const MethodChannel('login_with_amazon');

  /// Logs in to Amazon with the provided [scopes], returns user information
  static Future<Map> login(Map<String, dynamic> scopes) =>
      _channel.invokeMethod('login', scopes);

  /// Logs out of amazon
  static Future<bool> logout() => _channel.invokeMethod('logout');

  /// Retrieves the current access token with the provided [scopes]
  static Future<String> getAccessToken(Map<String, dynamic> scopes) =>
      _channel.invokeMethod('getAccessToken', scopes);
}
