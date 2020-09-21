//
//  SettingVC.swift
//  SentirLite
//
//  Created by TuanNguyen on 7/28/17.
//  Copyright © 2017 Skylab. All rights reserved.
//

import UIKit

enum DomainServer {
    case server1
    case server2
}

class SettingVC: BaseVC {
    @IBOutlet weak var saveBtnOutlet: UIButton!
    
    @IBAction func handleServer1Btn(_ sender: Any) {
        currentDomain = .server1
        updateDomainServer()
    }
    
    @IBAction func handleServer2Btn(_ sender: Any) {
        currentDomain = .server2
        updateDomainServer()
    }
    
    @IBOutlet weak var checkboxServer1Btn: UIButton!
    
    @IBOutlet weak var checkboxServer2Btn: UIButton!
    
    @IBAction func saveBtn(_ sender: Any) {
        
        self.confirmPopup(title: "Setting", subTitle: "Are you sure you want to change this domain ?") {
            
            if self.currentDomain == .server1 {
                URLs.domain = URLs.server1
            } else {
                URLs.domain = URLs.server2
            }
            URLs.login = URLs.domain + "/api/v1/login"
            URLs.cameraList = URLs.domain + "/api/v1/camera/list"
            URLs.cameraView = URLs.domain + "/api/v1/camera/view/"
            URLs.cameraStatus = URLs.domain + "/api/v1/camera/status"
            URLs.recordList = URLs.domain + "/api/v1/camera/record"
            URLs.addCamera = URLs.domain + "/api/v1/camera/PnP"
            UserDefaults.standard.set(URLs.domain, forKey: "Domain")
            NotificationCenter.default.post(name: kUserReLogin, object: nil)
        }
    }
    
    @IBAction func logOutBtn(_ sender: Any) {
        
        NotificationCenter.default.post(name: kUserReLogin, object: nil)
        
    }
    
    var currentDomain: DomainServer = .server1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveBtnOutlet.setTitle("Save", for: .normal)
        self.hideKeyboard()
        
        if URLs.domain == URLs.server1 {
            currentDomain = .server1
        } else {
            currentDomain = .server2
        }
        updateDomainServer()
    }


    func updateDomainServer() {
        if currentDomain == .server1 {
            checkboxServer1Btn.setImage(#imageLiteral(resourceName: "checked_checkbox"), for: .normal)
            checkboxServer2Btn.setImage(#imageLiteral(resourceName: "unchecked_checkbox"), for: .normal)
        } else {
            checkboxServer1Btn.setImage(#imageLiteral(resourceName: "unchecked_checkbox"), for: .normal)
            checkboxServer2Btn.setImage(#imageLiteral(resourceName: "checked_checkbox"), for: .normal)
        }
    }
}
