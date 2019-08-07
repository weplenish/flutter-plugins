import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:login_with_amazon/login_with_amazon.dart';

void main() {
  const MethodChannel channel = MethodChannel('login_with_amazon');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await LoginWithAmazon.platformVersion, '42');
  });
}
