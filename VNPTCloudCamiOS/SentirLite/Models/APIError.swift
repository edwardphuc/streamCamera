//
//  APIError.swift
//  SentirLite
//
//  Created by Hung Nguyen on 7/25/17.
//  Copyright © 2017 Skylab. All rights reserved.
//

import Foundation

struct APIError {
    var code:String = ""
    var msg:String = "Error"
    var detail:String = ""
    var show : String = ""
    
    init?(dict: [String:Any]) {
        self.code = dict["error"] as? String ?? ""
        self.msg = dict["message"] as? String ?? ""
    }
    
    init(code:String, msg:String, detail:String, show: String) {
        self.code = code
        self.msg = msg
        self.detail = detail
        self.show = show
    }
}

extension APIError {
    
    static func getError(from dict:Dictionary<String,Any>) -> APIError? {
        
        let errorArr = dict

        return APIError(dict: errorArr)
        
    }
}
