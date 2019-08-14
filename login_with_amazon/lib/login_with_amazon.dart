import 'dart:async';

import 'package:flutter/services.dart';

/// Flutter LWA plugin to handle platform specific implementations
class LoginWithAmazon {
  /// Channel for speaking to the platforms
  static const MethodChannel _channel =
      const MethodChannel('login_with_amazon');

  /// Logs in to Amazon with the provided [scopes]
  /// {
  ///   'profile': null,
  ///   'alexa:all': {
  ///     'productID': 'SomeProductId',
  ///     'productInstanceAttributes': {
  ///       'deviceSerialNumber': 'serialNumberHere',
  ///     },
  ///   },
  /// }
  ///
  /// To ensure successful login, check that the accessToken is not null
  ///
  /// returns
  /// {
  ///     'accessToken': 'access token result',
  ///     'user': {
  ///         'userEmail': 'user email result',
  ///         'userId': 'user id result',
  ///         'userName': 'user name result',
  ///         'userPostalCode': 'user postal code result',
  ///         'user info': 'user info as a Map<String,String> result',
  ///     },
  /// }
  static Future<Map> login(Map<String, dynamic> scopes) =>
      _channel.invokeMethod('login', scopes);

  /// To retrieve an authcode for an amazon dash device through LWA your dash device requires
  /// code verifier generation. This code verifier should be unique to the device.
  ///
  /// [scopes] should look like
  /// {
  ///   'profile': null,
  ///   'dash:replenish': {
  ///     'device_model': 'SomeDeviceModel',
  ///     'serial': 'serialNumberHere',
  ///     'is_test_device': true
  ///   },
  /// }
  ///
  /// [codeVerifier] should be a string between 43 and 128 characters long and
  /// contain url and filename safe characters only
  /// ([A-Z], [a-z], [0-9], "-", "_ ", ".", "~")
  ///
  /// For more information:
  /// https://developer.amazon.com/docs/dash/lwa-mobile-sdk.html#prerequisites
  static Future<Map> getAuthCode(
          String codeVerifier, Map<String, dynamic> scopes) =>
      _channel.invokeMethod('getAuthCode', {
        'codeVerifier': codeVerifier,
        'scopes': scopes,
      });

  /// Logs out of amazon
  static Future<bool> logout() => _channel.invokeMethod('logout');

  /// Retrieves the current access token with the provided [scopes]
  static Future<String> getAccessToken(Map<String, dynamic> scopes) =>
      _channel.invokeMethod('getAccessToken', scopes);
}
