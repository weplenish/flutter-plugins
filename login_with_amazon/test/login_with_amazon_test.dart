import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:login_with_amazon/login_with_amazon.dart';

/// @nodoc
void main() {
  const MethodChannel channel = MethodChannel('login_with_amazon');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'login':
          return {'accessToken': 'amazonianLoginToken'};
        case 'logout':
          return true;
        case 'getAccessToken':
          return 'amazonianAccessToken';
        default:
          return false;
      }
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getAccessToken', () async {
    expect(await LoginWithAmazon.getAccessToken({}), 'amazonianAccessToken');
  });

  test('logout', () async {
    expect(await LoginWithAmazon.logout(), true);
  });

  test('login', () async {
    expect(await LoginWithAmazon.login({}),
        {'accessToken': 'amazonianLoginToken'});
  });
}
