import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_flutter/wifi_flutter.dart';

void main() {
  const MethodChannel channel = MethodChannel('wifi_flutter');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await WifiFlutter.platformVersion, '42');
  });
}
