//
//  CameraDataSource.swift
//  SentirLite
//
//  Created by Hung Nguyen on 7/25/17.
//  Copyright © 2017 Skylab. All rights reserved.
//

import Foundation
import Alamofire

class CameraDataSource {
    
    func getListCamera(headers: [String:String] , completion:(([Camera]) -> ())?, error:((APIError)->())?){
        
        Alamofire.request(URLs.cameraList, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseData) in
            
            guard let data = responseData.result.value as? [String: Any] else {
                if let err = responseData.result.error  {
                    if let errCode = responseData.response?.statusCode {
                        error?(APIError(code: "error \(errCode)", msg: err.localizedDescription, detail: err.localizedDescription , show: ""))
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
            
            if var err = APIError.getError(from: data) {
                guard let errCode = responseData.response?.statusCode else {return}
                if err.msg != "" {
                    err.code = "error \(errCode)"
                    error?(err)
                    return
                }
            }
           
            guard let listCameraJS = data["camera_list"] as? [String : Any] else { return }
            
            guard let listCameraDefault = listCameraJS["DEFAULT"] as? [[String: Any]] else { return }
            
            var listCamera : [Camera] = []

            for item in listCameraDefault {
                if let camera = Camera(dict: item) {
                    
                    listCamera.append(camera)
                    
                }
            }
            completion?(listCamera)
        }
        
    }
    
    func getLinkVideo(cameraCode: String,headers: [String:String] , completion:((String) -> ())?, error:((APIError)->())?){
        
        Alamofire.request(URLs.cameraView + cameraCode, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseData) in
            
            guard let data = responseData.result.value as? [String: Any] else {
                if let err = responseData.result.error  {
                    if let errCode = responseData.response?.statusCode {
                        error?(APIError(code: "error \(errCode)", msg: err.localizedDescription, detail: err.localizedDescription , show: ""))
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
            
            if let URLString = data["url"] as? String {
                print(URLString)
                completion?(URLString)
            }
  
            if var err = APIError.getError(from: data) {
                guard let errCode = responseData.response?.statusCode else {return}
                if err.msg != "" {
                    err.code = "error \(errCode)"
                    error?(err)
                    return
                }

            }
        }
        
    }
    func getListCameraRecord(headers: [String:String],cameraCode:String,time:String, completion:(([Record]) -> ())?, error:((APIError)->())?){
        
        Alamofire.request(URLs.recordList+"/\(cameraCode)"+"/\(time)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseData) in
            var listRecord : [Record] = []
            guard let data = responseData.result.value as? [String: Any] else {
                if let err = responseData.result.error  {
                    if let errCode = responseData.response?.statusCode {
                        error?(APIError(code: "error \(errCode)", msg: err.localizedDescription, detail: err.localizedDescription , show: ""))
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
            
            if var err = APIError.getError(from: data) {
                guard let errCode = responseData.response?.statusCode else {return}
                if err.msg != "" {
                    err.code = "error \(errCode)"
                    error?(err)
                    return
                }
            }
            
            if let listRecordJS = data["record_list"] as? [String : Any] {
                
                let keys = listRecordJS.keys.sorted(by: { (s1, s2) -> Bool in
                    return s1 > s2
                })
                
                for k in keys {
                    
                    if let item = listRecordJS[k] as? JS {
                        if let cam = Record(dict: item) {
                            
                            listRecord.append(cam)
                            
                        } else {
                            print("can't prase JS")
                        }
                    }
                    
                }
                
            } else {
                listRecord = []
            }
            
            completion?(listRecord)
        }
        
    }
    
    func checkStatusCamera(parameters: [String], headers: [String: String],sessionKey: String,completion:(([String: String]) -> ())?, error:((APIError)->())? ) {
        var request = URLRequest(url: URL(string: URLs.cameraStatus)!)
       
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(sessionKey, forHTTPHeaderField: "X-Tokens")

        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters)

        Alamofire.request(request)
            .responseJSON { responseData in
                // do whatever you want here
                guard let data = responseData.result.value as? [String: Any] else {
                    if let err = responseData.result.error  {
                        if let errCode = responseData.response?.statusCode {
                            error?(APIError(code: "error \(errCode)", msg: err.localizedDescription, detail: err.localizedDescription , show: ""))
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
                
                if var err = APIError.getError(from: data) {
                    guard let errCode = responseData.response?.statusCode else {return}
                    if err.msg != "" {
                        err.code = "error \(errCode)"
                        error?(err)
                        return
                    }
                }
                
                if let status = data["status"] as? [String: String] {
                    
                   completion?(status)
                    
                }
        }
        
    }
    
    func addCamera(parameters: [String: Any],headers: [String:String] , completion:(() -> ())?, error:((APIError)->())?) {
        Alamofire.request(URLs.addCamera, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseData) in
            

            if let result =  responseData.result.value as? String {
                if responseData.response?.statusCode == 404 {
                    error?(APIError(code: "404", msg: "Serial is invalid or already in use ", detail: "Server error", show: "Lỗi server"))
                    return
                }
                completion?()
                return
            }
            
            guard let data = responseData.result.value as? [String: Any] else {
                if let err = responseData.result.error  {
                    if let errCode = responseData.response?.statusCode {
                        error?(APIError(code: "error \(errCode)", msg: err.localizedDescription, detail: err.localizedDescription , show: ""))
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
            if var err = APIError.getError(from: data) {
                guard let errCode = responseData.response?.statusCode else {return}
                if err.msg != "" {
                    err.code = "error \(errCode)"
                    error?(err)
                    return
                }
            }
        }
        
    }
    
}
