#import "LoginWithAmazonPlugin.h"
#import <login_with_amazon/login_with_amazon-Swift.h>

@implementation LoginWithAmazonPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftLoginWithAmazonPlugin registerWithRegistrar:registrar];
}
@end
