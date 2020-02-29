//
//  LoginWithAmazonProxy.swift
//  Runner
//
//  Created by Eitan Stadtlander-Miller on 2/24/20.
//  Copyright © 2020 WePlenish. All rights reserved.
//

import Foundation
import LoginWithAmazon
 
class LoginWithAmazonProxy {
 
    static let sharedInstance = LoginWithAmazonProxy()
 
    func login(delegate: AIAuthenticationDelegate) {
        AIMobileLib.authorizeUser(forScopes: Settings.Credentials.SCOPES, delegate: delegate, options: [:])
    }
}
