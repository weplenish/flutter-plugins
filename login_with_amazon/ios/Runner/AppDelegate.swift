import UIKit
import Flutter
import LoginWithAmazon

import UIKit
import LoginWithAmazon



func mapToScope(key:String, value: Any) -> AMZNScope{
    switch type(of: value) {
    case is Dictionary<AnyHashable, AnyHashable>.Type:
        return AMZNScopeFactory.scope(withName: key, data: value as! [AnyHashable : Any])
    default:
        return AMZNScopeFactory.scope(withName: value as! String)
    }
}

func createScope(dict: Dictionary<String,Any>) -> [AMZNScope]{
    return dict.map(mapToScope)
}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, AIAuthenticationDelegate {
    var result : FlutterResult? = nil
    
    @available(iOS 9.0, *)
    override func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return AIMobileLib.handleOpen(url, sourceApplication: UIApplication.OpenURLOptionsKey.sourceApplication.rawValue)
    }
    
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
            let lwaChannel = FlutterMethodChannel(name: "login_with_amazon", binaryMessenger: controller.binaryMessenger)
            
            lwaChannel.setMethodCallHandler({
                [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
                self!.result = result;
                
                switch call.method {
                case "login":
                    guard let args = call.arguments as? [String : Any] else {
                        result(FlutterError(code: "No Args", message: nil, details: nil))
                        return
                    }
                    let scopes : Dictionary = (args["scopes"] as? Dictionary<String, Any>)!
                    
                    AIMobileLib.authorizeUser(forScopes: createScope(dict: scopes), delegate: self)
                    return
                case "getAuthCode":
                    guard let args = call.arguments as? [String : Any] else {
                        result(FlutterError(code: "No Args", message: nil, details: nil))
                        return
                    }
                    let scopes : Dictionary = (args["scopes"] as? Dictionary<String, Any>)!
                    let req = AMZNAuthorizeRequest.init()
                    req.scopes = createScope(dict: scopes)
                    req.grantType = AMZNAuthorizationGrantType.code
                    req.codeChallenge = args["codeChallenge"] as! String
                    req.codeChallengeMethod = args["codeChallengeMethod"] as! String
                    
                    AMZNAuthorizationManager.shared().authorize(req) { (res, canceled, error) in
                        if(canceled){
                            result(FlutterError(code: "User Canceled", message: "User Cancelled Request", details: nil))
                        }else if((error) != nil){
                            result(FlutterError(code: "Authorization Error", message: "An Error Occured", details: error))
                        }else{
                            result(res)
                        }
                    }
                    return
                case "logout":
                    AMZNAuthorizationManager.shared().signOut { (error) in
                        if((error) != nil) {
                            result(FlutterError(code: "Signout Failure", message: "User could not sign out", details: error))
                        }else{
                            AIMobileLib.clearAuthorizationState(self)
                            result(true)
                        }
                    }
                    return
                case "getAccessToken":
                    guard let args = call.arguments as? [String : Any] else {
                        result(FlutterError(code: "No Args", message: nil, details: nil))
                        return
                    }
                    let scopes : Dictionary = (args["scopes"] as? Dictionary<String, Any>)!
                    AIMobileLib.getAccessToken(forScopes: createScope(dict: scopes), withOverrideParams: nil, delegate: self)
                    return
                default:
                    result(FlutterMethodNotImplemented)
                    return
                }
            })

            GeneratedPluginRegistrant.register(with: self)
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
          }
    
    func requestDidSucceed(_ apiResult: APIResult) {
       if (apiResult.api == API.authorizeUser) {
           AIMobileLib.getAccessToken(forScopes: ["Profile"], withOverrideParams: nil, delegate: self)
       }
       else {
        result!(apiResult.result)
       }
   }
    
   func requestDidFail(_ errorResponse: APIError) {
    result!(FlutterError(code: "LWA Failure", message: "Bad Request", details: errorResponse))
   }
}
