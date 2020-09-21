//
//  Record.swift
//  SentirLite
//
//  Created by TuanNguyen on 7/27/17.
//  Copyright © 2017 Skylab. All rights reserved.
//

import Foundation
struct Record {
    
    var id: String = ""
    
    var cameraCode: String = ""
    
    var startTime: String = ""
    
    var endTime: String = ""
    
    var recordFile: String = ""
    
    var type: String = ""
    
    var viewRecordUrl: String = ""
    
    var isPlaying: Bool = false
    var seekToTime: TimeInterval?
    
    var secondStart : Int {
        get {
            if startTime != "" {
               let hour = (TimeInterval(exactly: Int(startTime)!)?.format2String(format: "HH"))!
                let min =  (TimeInterval(exactly: Int(startTime)!)?.format2String(format: "mm"))!
                let sec = (TimeInterval(exactly: Int(startTime)!)?.format2String(format: "ss"))!
                return  Int(hour)! * 3600 + Int(min)! * 60 + Int(sec)!

            }
            return 0
        }
    }
    var secondEnd : Int {
        get {
            if endTime != "" {
                let hour = (TimeInterval(exactly: Int(endTime)!)?.format2String(format: "HH"))!
                let min =  (TimeInterval(exactly: Int(endTime)!)?.format2String(format: "mm"))!
                let sec = (TimeInterval(exactly: Int(endTime)!)?.format2String(format: "ss"))!
                return  Int(hour)! * 3600 + Int(min)! * 60 + Int(sec)!
                
            }
            return 0
        }
    }
    
    init?(dict: JS) {
        
        self.id             = dict["id"] as? String ?? ""

        self.cameraCode     = dict["camera_code"] as? String ?? ""
        
        self.startTime      = dict["start_time"] as? String ?? ""
        
        self.endTime        = dict["end_time"] as? String ?? ""
        
        self.recordFile     = dict["record_file"] as? String ?? ""
        
        self.type           = dict["type"] as? String ?? ""
        
        self.viewRecordUrl  = dict["view_record_url"] as? String ?? ""
        
    }
    
}
