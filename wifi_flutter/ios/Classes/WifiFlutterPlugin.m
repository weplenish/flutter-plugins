#import "WifiFlutterPlugin.h"
#import <wifi_flutter/wifi_flutter-Swift.h>

@implementation WifiFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftWifiFlutterPlugin registerWithRegistrar:registrar];
}
@end
