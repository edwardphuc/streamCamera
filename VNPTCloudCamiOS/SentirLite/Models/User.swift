//
//  User.swift
//  SentirLite
//
//  Created by TuanNguyen on 7/26/17.
//  Copyright © 2017 Skylab. All rights reserved.
//

import Foundation

typealias JS = [String:Any]

protocol CanParseJS {
    init?(dict:JS)
    func toDict() -> JS
}

struct UserInformation:CanParseJS {
    var name: String
    var email: String
    var password: String
    var isLogin:Bool
    
    

    init?(dict: JS) {
        self.name           = dict["name"] as? String ?? ""
        self.email          = dict["email"] as? String ?? ""
        self.password       = dict["password"] as? String ?? ""
        self.isLogin        = dict["isLogin"]   as? Bool ?? true

    }
    
    func toDict() -> JS {
        let dict : JS = [
            "name"          : self.name,
            "email"         : self.email,
            "password"      : self.password,
            "isLogin"       : self.isLogin
        ]
        return dict
    }
}

struct User:CanParseJS {
    var userInformation    : UserInformation?
    var sessionKey: String = ""

    init?(dict: JS) {
        guard let sessionKey = dict["session_key"] as? String else {return}
        if let user = dict["user"] as? JS {
            self.userInformation = UserInformation(dict: user)
        }
        self.sessionKey = sessionKey
    }

    
    func toDict() -> JS {
        let dict : JS = [
            "user"              : self.userInformation?.toDict() ?? [:],
            "session_key"       : self.sessionKey
        ]
        return dict
    }
    
}
