import Flutter
import UIKit

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

func getArguments(arguments: Any?) -> [String: Any]{
  guard let args = arguments as? [String : Any] else {
    return [:]
  }
  return args
}

func getScopes(args: [String: Any]) -> Dictionary<String, Any> {
  guard let scopes : Dictionary = args["scopes"] as? Dictionary<String, Any> else {
    return [:]
  }
  return scopes
}

func ReqHandler(result: @escaping FlutterResult) -> AMZNAuthorizationRequestHandler {
  return {(res, cancelled, error) in
      if(cancelled){
        DispatchQueue.main.async {
          result(FlutterError(code: "User Canceled", message: "User Cancelled Request", details: nil))
        }
      }else if((error) != nil){
        DispatchQueue.main.async {
          result(FlutterError(code: "Authorization Error", message: "An Error Occured", details: error))
        }
      }else{
        DispatchQueue.main.async {
          result(res)
        }
      }
    
  }
}

func AMZNReqFromFlutterArgs(arguments: Any?) -> AMZNAuthorizeRequest {
  let args = getArguments(arguments: arguments)
  let scopes = getScopes(args: args)
  let req = AMZNAuthorizeRequest.init()
  req.scopes = createScope(dict: scopes)
  
  if(args["codeChallenge"] != nil){
    req.codeChallenge = args["codeChallenge"] as! String
  }
  if(args["codeChallengeMethod"] != nil){
    req.codeChallengeMethod = args["codeChallengeMethod"] as! String
  }
  return req
}

public class SwiftLoginWithAmazonPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "login_with_amazon", binaryMessenger: registrar.messenger())
    let instance = SwiftLoginWithAmazonPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      case "login":
        //let args = getArguments(arguments: call.arguments)
        //let scopes = getScopes(args: args)
        //AIMobileLib.authorizeUser(forScopes: createScope(dict: scopes), delegate: self)
        
        let req = AMZNReqFromFlutterArgs(arguments: call.arguments)
        req.grantType = AMZNAuthorizationGrantType.token
        AMZNAuthorizationManager.shared().authorize(req, withHandler: ReqHandler(result: result))
        return
      case "getAuthCode":
        let req = AMZNReqFromFlutterArgs(arguments: call.arguments)
        req.grantType = AMZNAuthorizationGrantType.code
        AMZNAuthorizationManager.shared().authorize(req, withHandler: ReqHandler(result: result))
        return
      case "logout":
        AMZNAuthorizationManager.shared().signOut { (error) in
            if((error) != nil) {
                result(FlutterError(code: "Signout Failure", message: "User could not sign out", details: error))
            }else{
                //AIMobileLib.clearAuthorizationState(self)
                result(true)
            }
        }
        return
      case "getAccessToken":
        result(FlutterMethodNotImplemented)
        //let args = getArguments(arguments: call.arguments)
        //let scopes = getScopes(args: args)
        //AIMobileLib.getAccessToken(forScopes: createScope(dict: scopes), withOverrideParams: nil, delegate: self)
        return
      default:
        result(FlutterMethodNotImplemented)
        return
    }
  }
}

