//
//  Domain.swift
//  SentirLite
//
//  Created by Hung Nguyen on 7/25/17.
//  Copyright © 2017 Skylab. All rights reserved.
//

import Foundation

struct URLs {
   
    static var domain       = "https://sentirlite.com"
   
    //API Login
    static var login = domain + "/api/v1/login"
  
    //API Get List Camera
    static var cameraList = domain + "/api/v1/camera/list"
    
    //API Get link Camera
    static var cameraView = domain + "/api/v1/camera/view/"
   
    //API Check status camera
    static var cameraStatus = domain + "/api/v1/camera/status"
   
    //API Get list record
    static var recordList = domain + "/api/v1/camera/record"
    
    // Webview change password
    static var changePassword = "https://sentirlite.com/cameras/thay-doi-mat-khau/"
    
    //Add camera to my list
    static var addCamera = domain + "/api/v1/camera/PnP"
    
    static var server2 = ""
    
    static let server1 = "https://sentirlite.com"
    
}
