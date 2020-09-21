//
//  LoginSettingVC.swift
//  SentirLite
//
//  Created by TuanNguyen on 7/28/17.
//  Copyright © 2017 Skylab. All rights reserved.
//

import UIKit

class LoginSettingVC: BaseVC {
    @IBOutlet weak var urlTF: FloatLabelTextField!
    @IBOutlet weak var settingLbl: UILabel!
    @IBOutlet weak var saveBtnOutlet: UIButton!
    
    static let identifier = "LoginSettingVC"
    class func newVC() ->  LoginSettingVC{
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyBoard.instantiateViewController(withIdentifier: identifier) as! LoginSettingVC
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        urlTF.text = URLs.domain
        settingLbl.text = NSLocalizedString("setting", comment: "")
        self.saveBtnOutlet.setTitle(NSLocalizedString("save", comment: ""), for: .normal)
        self.hideKeyboard()

    }

    func keyboardWillHide(notification: NSNotification) {
        self.view.layoutIfNeeded()
       self.removeTapGesture()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func saveBtn(_ sender: Any) {
        URLs.domain = urlTF.text ?? "https://sentirlite.com"
        
        //API Login
        URLs.login = URLs.domain + "/api/v1/login"
        
        //API Get List Camera
        URLs.cameraList = URLs.domain + "/api/v1/camera/list"
        
        //API Get link Camera
        URLs.cameraView = URLs.domain + "/api/v1/camera/view/"
        
        //API Check status camera
        URLs.cameraStatus = URLs.domain + "/api/v1/camera/status"
        
        //API Get list record
        URLs.recordList = URLs.domain + "/api/v1/camera/record"
        
        
        self.confirmPopup(title: LocalizableKey.appName, subTitle: "\(NSLocalizedString("new_domain", comment: "")) \(URLs.domain)") {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    @IBAction func xBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
