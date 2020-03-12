import Flutter
import UIKit

func StringAny(dict: [String : Any]) -> [String : Any]{
  return Dictionary(uniqueKeysWithValues:
    dict.map { key, value in 
      guard let dictVal = value as? [String : Any] else {
        return (key, value)
      }
      return (key, StringAny(dict: dictVal))
    }
  )
}

func CreateScope(dict: [String : Any]) -> [AMZNScope]{
  return dict.map{ key, value in
    guard let data = value as? [String : Any] else {
      return AMZNScopeFactory.scope(withName: key)
    }
    return AMZNScopeFactory.scope(withName: key, data: StringAny(dict: data))
  }
}

func ReqHandler(result: @escaping FlutterResult) -> AMZNAuthorizationRequestHandler {
  return { res, cancelled, error in
    DispatchQueue.main.async {
      guard !cancelled else {
        result(FlutterError(code: "User Canceled", message: "User Cancelled Request", details: nil))
      }
      guard error != nil else {
        result(res)
      }
      result(FlutterError(code: "Authorization Error", message: "An Error Occured", details: error))
    }
  }
}

enum ArgsError: Error {
  case MissingArgs
  case MissingScopes
}

func GetArgs(arguments: Any?) throws -> [String : Any]{
  guard let args = arguments as? [String : Any] else {
    throw ArgsError.MissingArgs
  }
  return args
}

func GetScopes(arguments: [String : Any]) throws -> [AMZNScope]{
  guard let scopes = arguments["scopes"] as? [String : Any] else {
    throw ArgsError.MissingScopes
  }
  return CreateScope(dict: scopes)
}

func AMZNReqFromFlutterArgs(arguments: Any?) throws -> AMZNAuthorizeRequest {
  let args = try GetArgs(arguments: arguments)
  let req = AMZNAuthorizeRequest.init()
  req.scopes = try GetScopes(arguments: args)
  
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
    do {
      switch call.method {
        case "login":
          let req = try AMZNReqFromFlutterArgs(arguments: call.arguments)
          req.grantType = AMZNAuthorizationGrantType.token
          AMZNAuthorizationManager.shared().authorize(req, withHandler: ReqHandler(result: result))
          return
        case "getAuthCode":
          let req = try AMZNReqFromFlutterArgs(arguments: call.arguments)
          req.grantType = AMZNAuthorizationGrantType.code
          AMZNAuthorizationManager.shared().authorize(req, withHandler: ReqHandler(result: result))
          return
        case "logout":
          AMZNAuthorizationManager.shared().signOut { error in
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
          //let args = try GetArgs(arguments: call.arguments)
          //let scopes = try GetScopes(arguments: args)
          //AIMobileLib.getAccessToken(forScopes: createScope(dict: scopes), withOverrideParams: nil, delegate: self)
          return
        default:
          result(FlutterMethodNotImplemented)
          return
      }
    } catch ArgsError.MissingArgs {
      result(FlutterError(code: "Missing Arguments", message: "Arguments required", details: nil))
    } catch ArgsError.MissingScopes {
      result(FlutterError(code: "Missing Scopes", message: "Scopes required", details: nil))
    } catch {
      result(FlutterError(code: "Something went wrong", message: ":(", details: nil))
    }
  }
}
