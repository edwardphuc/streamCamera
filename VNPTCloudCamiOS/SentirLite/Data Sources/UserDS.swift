//
//  UserDS.swift
//  SentirLite
//
//  Created by TuanNguyen on 7/26/17.
//  Copyright © 2017 Skylab. All rights reserved.
//
import Alamofire
class UserDS {
    //Login
    func Login(parameters : [String : Any], header : [String : String]? = nil, competition: ((User) -> ())?, error: ((APIError) -> ())?) {
        Alamofire.request(URLs.login, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header).responseJSON { (response) in
            guard let resJS = response.result.value as? [String : Any] else {
                if let err = response.result.error  {
                    if let errCode = response.response?.statusCode {
                        error?(APIError(code: "error \(errCode)", msg: err.localizedDescription, detail: err.localizedDescription , show: "Lỗi server"))
                    } else {
                        
                        if err.localizedDescription.range(of: "A server with the specified hostname could not be found") != nil {
                            error?(APIError(code: LocalizableKey.appName, msg: NSLocalizedString("dialogErrorURL", comment: ""), detail: err.localizedDescription , show: "Lỗi server"))
                        } else {
                            error?(APIError(code: LocalizableKey.appName, msg: NSLocalizedString("no_internet_connection", comment: ""), detail: err.localizedDescription , show: "Lỗi server"))
                        }

                    }
                    
                } else {
                    error?(APIError(code: "ALERT", msg: "Error, pls try again.", detail: "Server error", show: "Lỗi server"))
                }
                
                return
            }
            print(resJS)
            if var err = APIError.getError(from: resJS) {
                guard let errCode = response.response?.statusCode else {return}
                if err.msg != "" {
                    err.code = "error \(errCode)"
                    error?(err)
                    return
                }
            }
            
            if let user : User = User(dict: resJS) {
                
                competition?(user)
                
            }
        }
    }

        
    
}
