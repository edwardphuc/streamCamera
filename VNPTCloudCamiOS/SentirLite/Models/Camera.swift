//
//  Camera.swift
//  SentirLite
//
//  Created by Hung Nguyen on 7/25/17.
//  Copyright © 2017 Skylab. All rights reserved.
//

import Foundation

struct Camera {
    
    var id: Int = 0
    
    var groupID: Int = 0
    
    var cameraCode: String = ""
    
    var cameraName: String = ""
    
    var cameraSerial: String = ""
    
    var cameraMode: String = ""
    
    var status: Int = 0
    
    var createdGroup: Int = 0
    
    var createdUser: Int = 0
    
    init?(dict: [String: Any]) {
        
        self.id = dict["id"] as? Int ?? 0
        
        self.groupID = dict["group_id"] as? Int ?? 0
        
        self.cameraCode = dict["camera_code"] as? String ?? ""
        
        self.cameraName = dict["camera_name"] as? String ?? ""
        
        self.cameraMode = dict["camera_mode"] as? String ?? ""
        
        self.status = dict["status"] as? Int ?? 0
    
        self.createdGroup = dict["created_group"] as? Int ?? 0
        
        self.createdUser = dict["created_user"] as? Int ?? 0
    }

}
