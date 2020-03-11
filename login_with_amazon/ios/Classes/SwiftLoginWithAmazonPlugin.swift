import Flutter
import UIKit

func dictToHashable(dict: [Any : Any]) throws -> [AnyHashable : Any]{
  let hashableDict: [AnyHashable : Any] = [:]
  for (key, value) in dict {
    if let hashedKey = key as? AnyHashable {
      if let dictVal = value as? [Any : Any]{
        hashableDict[hashedKey] = try dictToHashable(dict: dictVal)
      }else{
        hashableDict[hashedKey] = value
      }
    }else{
      throw ArgsError.ScopeFailure
    }
  }
  return hashableDict
}

func mapToScope(key:String, value: Any) throws -> AMZNScope{
    if let data = value as? [Any : Any] {
        return AMZNScopeFactory.scope(withName: key, data: try dictToHashable(dict: data))
    }else if let name = value as? String {
        return AMZNScopeFactory.scope(withName: name)
    } else {
        throw ArgsError.ScopeFailure
    }
}

func createScope(dict: [String: Any]) throws -> [AMZNScope]{
  return try dict.map(mapToScope)
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

enum ArgsError: Error {
    case MissingArgs
    case ScopeFailure
}

func AMZNReqFromFlutterArgs(arguments: Any?) throws -> AMZNAuthorizeRequest {
    if let args = arguments as? [String: Any],
    let scopes = args["scopes"] as? [String: Any] {
      let req = AMZNAuthorizeRequest.init()
      do{
        req.scopes = try createScope(dict: scopes)
      }catch {
        throw ArgsError.ScopeFailure
      }
      
      if(args["codeChallenge"] != nil){
        req.codeChallenge = args["codeChallenge"] as! String
      }
      if(args["codeChallengeMethod"] != nil){
        req.codeChallengeMethod = args["codeChallengeMethod"] as! String
      }
      return req
    }else{
        throw ArgsError.MissingArgs
    }
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
            //let args = getArguments(arguments: call.arguments)
            //let scopes = getScopes(args: args)
            //AIMobileLib.authorizeUser(forScopes: createScope(dict: scopes), delegate: self)
            
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
    } catch ArgsError.MissingArgs {
      result(FlutterError(code: "Missing Arguments", message: "Scopes required", details: nil))
    } catch ArgsError.ScopeFailure {
      result(FlutterError(code: "Bad Scopes", message: "Scopes are malformed", details: nil))
    } catch {
      result(FlutterError(code: "Something went wrong", message: ":(", details: nil))
    }
  }
}

