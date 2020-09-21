//
//  AddCameraVC.swift
//  SentirLite
//
//  Created by Hung Nguyen on 10/16/17.
//  Copyright © 2017 Skylab. All rights reserved.
//

import UIKit
import Alamofire

class AddCameraVC: BaseVC {

    static let identifier = "AddCameraVC"
    
    @IBOutlet weak var cameraNameTF: UITextField!
    
    @IBOutlet weak var cameraSerialTF: UITextField!
    
    @IBAction func back(_ sender: Any) {
        NotificationCenter.default.post(name: kDismissView, object: nil)
    }
    @IBAction func addCamera(_ sender: Any) {
        guard let cameraName = cameraNameTF.text else {return}
        guard let cameraSerial = cameraSerialTF.text else {return}

        addCamera(cameraName: cameraName, cameraSerial: cameraSerial)
    
    }
    
    var cameraDS: CameraDataSource = CameraDataSource()
    let ad = UIApplication.shared.delegate as! AppDelegate
    var token: String = "f0e17ff68f2089a1dff5b7c8280b8c92"
    class func newVC() ->  AddCameraVC {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyBoard.instantiateViewController(withIdentifier: identifier) as! AddCameraVC
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name:UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        var info = notification.userInfo!
        
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let heightKeyboard = keyboardFrame.size.height
        hideKeyboard()
        UIView.animate(withDuration: 0.1, animations: {
            self.view.layoutIfNeeded()
        })
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.removeTapGesture()
            
            self.view.layoutIfNeeded()
        })
    }
    func addCamera(cameraName: String, cameraSerial: String) {
        
        let sessionKey = ad.logginUser?.sessionKey
        
        let headers: [String: String] = [
            
            "X-Tokens": sessionKey ?? token,
            "Content-Type" : "application/json"
        ]
        let parameters: [String: Any] = [
            "name": cameraName,
            "serial": cameraSerial,
        ]
        cameraDS.addCamera(parameters: parameters, headers: headers, completion: { 
            self.errorPopup(title: "Success", subTitle: "Add camera success", completion: {
                NotificationCenter.default.post(name: kDismissView, object: nil)
            })
        }) { (error) in
            self.errorPopup(title: "Alert", subTitle: error.msg, completion: nil)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}
