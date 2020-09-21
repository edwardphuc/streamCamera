//
//  LoginVC.swift
//  SentirLite
//
//  Created by TuanNguyen on 7/26/17.
//  Copyright © 2017 Skylab. All rights reserved.
//

import UIKit
import SwiftValidator

class LoginVC: BaseVC,ValidationDelegate,UITextFieldDelegate {
   
    static let identifier = "LoginVC"
    class func newVC() ->  LoginVC{
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyBoard.instantiateViewController(withIdentifier: identifier) as! LoginVC
        return vc
    }
   
    @IBOutlet weak var emailLbl: FloatLabelTextField!
    @IBOutlet weak var rememberMeLbl: UILabel!
    @IBOutlet weak var loginBtnOutlet: UIButton!
    @IBOutlet weak var passwordLbl: FloatLabelTextField!
    @IBOutlet weak var emailErrLbl: UILabel!
    @IBOutlet weak var passwordErrLbl: UILabel!
    @IBOutlet weak var rememberUserSwitch: UISwitch!
    
    @IBOutlet weak var bottomConstraintOfLogoImg: NSLayoutConstraint!
    @IBOutlet weak var topConstraintOfLogoImg: NSLayoutConstraint!
    
    @IBAction func handleServer1Btn(_ sender: Any) {
        currentDomain = .server1
        updateUICheckbox()
    }
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBAction func handleServer2Btn(_ sender: Any) {
        print(URLs.server2)
        currentDomain = .server2
        updateUICheckbox()
    }
    
    @IBOutlet weak var checkboxServer1Btn: UIButton!
    
    @IBAction func changeScreen(_ sender: Any) {
        print("hello")
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let server2 = sb.instantiateViewController(withIdentifier: "Server2VC")
        server2.modalPresentationStyle = .fullScreen
        self.present(server2, animated: true)
        
    }
    @IBOutlet weak var checkboxServer2Btn: UIButton!
    @IBAction func switchBtn(_ sender: UISwitch) {
        if sender.isOn {
           
            UserDefaults.standard.set(true, forKey: "SwitchState")
          
            self.isRemeberUser = true
            
        } else {
          
            UserDefaults.standard.set(false, forKey: "SwitchState")
           
            self.isRemeberUser = false
        }
    }
    
    var iconClick : Bool = true
    
    var userDS:UserDS = UserDS()
    
    var isRemeberUser:Bool = false
    
    let ad = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var panel: UIView!
    let validator = Validator()
    var currentDomain: DomainServer = .server1
    @objc func showserver(){
        panel.isHidden = true
        UserDefaults.standard.setValue("hide", forKey: "panel")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLocalizeString()
        passwordLbl.returnKeyType = .done
        passwordLbl.delegate = self
        emailLbl.returnKeyType = .done
        emailLbl.delegate = self
        resetErr()
        validator.registerField(emailLbl,errorLabel: emailErrLbl, rules: [RequiredRule()])
        validator.registerField(passwordLbl,errorLabel: passwordErrLbl, rules: [RequiredRule()])
        let switchState = UserDefaults.standard.bool(forKey: "SwitchState")
        self.rememberUserSwitch.isOn = switchState
        self.isRemeberUser = switchState
        let tap = UITapGestureRecognizer(target: self, action: #selector(showserver))
        tap.numberOfTapsRequired = 7
        panel.addGestureRecognizer(tap)
        UserDefaults.standard.setValue("show", forKey: "panel")
        if switchState {
            if let userDict = UserDefaults.standard.dictionary(forKey: "userDict"){
                
                let user = User(dict: userDict)
                
                self.emailLbl.text = user?.userInformation?.email

                self.passwordLbl.text = user?.userInformation?.password
                
            }

        } else {
            
            self.emailLbl.text = ""
            
            self.passwordLbl.text = ""
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name:UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name:UIResponder.keyboardWillHideNotification, object: nil)
//        self.settingBtn.isHidden = true
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if URLs.domain == URLs.server1 {
            currentDomain = .server1
        } else {
            currentDomain = .server2
        }
        updateUICheckbox()
    }
    
    @IBAction func showPassBtn(_ sender: Any) {
        if(iconClick == true) {
            passwordLbl.isSecureTextEntry = false
            iconClick = false
        } else {
            passwordLbl.isSecureTextEntry = true
            iconClick = true
        }
    }
    
    func resetErr() {
       
        emailErrLbl.isHidden = true
        
        passwordErrLbl.isHidden = true
    }
    
    func setUpLocalizeString() {
        self.emailLbl.placeholder       = NSLocalizedString("email", comment: "")
        self.passwordLbl.placeholder    = NSLocalizedString("password", comment: "")
        self.rememberMeLbl.text         = NSLocalizedString("remember_me", comment: "")
        self.loginBtnOutlet.setTitle(NSLocalizedString("login", comment: ""), for: .normal)
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        var info = notification.userInfo!
        
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let heightKeyboard = keyboardFrame.size.height
        hideKeyboard()
        UIView.animate(withDuration: 0.1, animations: {
            self.bottomConstraint.constant = heightKeyboard 
            self.bottomConstraintOfLogoImg.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.bottomConstraintOfLogoImg.constant = 26
            self.bottomConstraint.constant = 50
            self.removeTapGesture()
            self.view.layoutIfNeeded()
        })
    }
    
    
    func validationSuccessful(){
        resetErr()
        let userName = emailLbl.text
        let userPassword = passwordLbl.text
        
        let header : [String:String] = [
            "Content-Type" : "application/x-www-form-urlencoded"
        ]
        let  para : [String : Any]  = [
            "email"     : userName!,
            "password"  : userPassword!
            
        ]
        userDS.Login(parameters: para, header: header, competition: { (user) in
            var user: User = user
            user.userInformation?.password = userPassword ?? ""
            user.userInformation?.isLogin = true
            let userDict = user.toDict()
            self.ad.logginUser = user
            NotificationCenter.default.post(name: kUserDidLogin, object: nil)

            if self.isRemeberUser {
                UserDefaults.standard.set(userDict, forKey: "userDict")
                UserDefaults.standard.synchronize()
            } else {
                UserDefaults.standard.removeObject(forKey: "userDict")
            }
            self.dismiss(animated: true, completion: nil)
        }) { (err) in
            if err.msg.range(of: "Cannot connect server, please change URL !") != nil {
                self.errorPopup(title: err.code, subTitle: err.msg, completion: nil)
            } else {
                self.errorPopup(title: err.code, subTitle: err.msg, completion: nil)
            }
        }
        
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        resetErr() // hide all error
        
        for (_, error) in errors {
            
            error.errorLabel?.text = NSLocalizedString("login_email_require", comment: "")// works if you added labels
            error.errorLabel?.isHidden = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginBtn(_ sender: Any) {
        changeDomain()
        validator.validate(self)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        validator.validate(self)
        return true
    }
    
    
    
    
    func updateUICheckbox() {
        if currentDomain == .server1 {
            checkboxServer1Btn.setImage(#imageLiteral(resourceName: "checked_checkbox"), for: .normal)
            checkboxServer2Btn.setImage(#imageLiteral(resourceName: "unchecked_checkbox"), for: .normal)
        } else {
            checkboxServer1Btn.setImage(#imageLiteral(resourceName: "unchecked_checkbox"), for: .normal)
            checkboxServer2Btn.setImage(#imageLiteral(resourceName: "checked_checkbox"), for: .normal)
        }
    }
    
    func changeDomain() {
        
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
    }
}
