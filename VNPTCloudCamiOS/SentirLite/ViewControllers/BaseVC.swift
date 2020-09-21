//
//  BaseVC.swift
//  SentirLite
//
//  Created by Hung Nguyen on 7/25/17.
//  Copyright © 2017 Skylab. All rights reserved.
//

import UIKit
import SVProgressHUD
import Jelly
import SCLAlertView

class BaseVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: kReceiveDisconnectionStatus, object: nil, queue: nil) { [weak self] (notif) in
            guard let `self` = self else { return }
            
            let ad = UIApplication.shared.delegate as! AppDelegate
            ad.showDisconnectDialog()
        }
        NotificationCenter.default.addObserver(forName: kReceiveHasConnectionStatus, object: nil, queue: nil) {  [weak self] (notif) in
            guard let `self` = self else { return }
            let ad = UIApplication.shared.delegate as! AppDelegate
            ad.dismissDisconnectDialog()
            
        }
  
    }

    

    func showLoading (msg:String? = nil) {
        self.view.isUserInteractionEnabled = false
        SVProgressHUD.show()
    }
    func isLoggedIn() -> Bool{
        let ad = UIApplication.shared.delegate as! AppDelegate

        if ad.logginUser != nil {
            return true
        } else {
            
            if let userDict = UserDefaults.standard.dictionary(forKey: "userDict"){
                let user = User(dict: userDict)
                ad.logginUser = user
                guard let checkLogin = user?.userInformation?.isLogin else {
                    return false
                }
                return checkLogin
            }
        }
        return false
    }
    func hideLoading (delay:TimeInterval) {
        SVProgressHUD.dismiss(withDelay: delay) {
            self.view.isUserInteractionEnabled = true
        }
    }
    fileprivate var jellyAnimator: JellyAnimator?
    
    fileprivate func createVC() -> UIViewController? {
        return self.storyboard?.instantiateViewController(withIdentifier: "PopUpVC")
    }
    func showFilterPopup(data : [FilterItem], tittle:String, delegate: PopUpVCDelegate? = nil, allowMultiSelection:Bool = false) {
        let screenRect: CGRect = UIScreen.main.bounds
        let screenWidth: CGFloat = screenRect.size.width
        let screenHeight: CGFloat = screenRect.size.height
        
        
        let defaultSlideInPresentation = JellySlideInPresentation(cornerRadius : 5,
                                                                  widthForViewController: .custom(value: screenWidth - 95 ),
                                                                  heightForViewController: .custom(value: screenHeight - 312)
            
        )
        let presentation = defaultSlideInPresentation
        let newVC = FilterPopUpVC.newVC()
        newVC.delegate = delegate
        newVC.allowMultiSelection = allowMultiSelection
        
        newVC.filterList = data
        newVC.tittlePopup = tittle

        self.jellyAnimator = JellyAnimator(presentation:presentation)
        self.jellyAnimator?.prepare(viewController: newVC)
        newVC.modalPresentationStyle = .fullScreen
        self.present(newVC, animated: true, completion: nil)
        
    }
    func showCalendarPickerPopup(filterType:String,data:DatePickerType,delegate:CalendarPickerVCDelegate? = nil) {
        let screenRect: CGRect = UIScreen.main.bounds
        let screenWidth: CGFloat = screenRect.size.width
        let screenHeight: CGFloat = screenRect.size.height
        
        
        let defaultSlideInPresentation = JellySlideInPresentation(cornerRadius : 5,
                                                                  widthForViewController: .custom(value: screenWidth - 95 ),
                                                                  heightForViewController: .custom(value: screenHeight - 312))
        let presentation = defaultSlideInPresentation
        let newVC = CalendarPickerVC.newVC()
        newVC.delegate = delegate
        newVC.datetype = data
        newVC.filterType = filterType
        self.jellyAnimator = JellyAnimator(presentation:presentation)
        self.jellyAnimator?.prepare(viewController: newVC)
        newVC.modalPresentationStyle = .fullScreen
        self.present(newVC, animated: true, completion: nil)
        
    }
    deinit {
        
        print("deinit \(self)")
        
        NotificationCenter.default.removeObserver(self)
        
    }
    func errorPopup(title : String, subTitle : String, completion: (() -> ())?){
        

        let appearance = SCLAlertView.SCLAppearance(kButtonFont: UIFont(name: "HelveticaNeue", size: 14)!, showCloseButton: false, showCircularIcon: false, buttonCornerRadius: 17)
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("OK", backgroundColor: #colorLiteral(red: 0.01176470588, green: 0.368627451, blue: 0.7176470588, alpha: 1)) {
            completion?()
        }
        alert.showError(title, subTitle: subTitle, animationStyle: .bottomToTop)
        
    }
    func confirmPopup(title : String, subTitle : String, yesAct : (()->())? ){
        
        let appearance = SCLAlertView.SCLAppearance(kButtonFont: UIFont(name: "HelveticaNeue", size: 14)!, showCloseButton: false, showCircularIcon: false, buttonCornerRadius: 17)
        let alert = SCLAlertView(appearance: appearance)
        
        alert.addButton("OK", backgroundColor: COLOR.mainBlueColor) {
            yesAct?()
        }
        let abc = alert.addButton("Cancel", backgroundColor: UIColor.white, textColor: COLOR.mainBlueColor) {
            alert.dismiss(animated: true, completion: nil)
        }
        abc.layer.borderColor = COLOR.mainBlueColor.cgColor
        abc.layer.borderWidth = 1
        alert.showError(title, subTitle: subTitle, animationStyle: .bottomToTop)
        
    }

    func getHoursMinutesSecondsFrom(seconds: Double) -> (hours: Int, minutes: Int, seconds: Int) {
        let secs = Int(seconds)
        let hours = secs / 3600
        let minutes = (secs % 3600) / 60
        let seconds = (secs % 3600) % 60
        return (hours, minutes, seconds)
    }
    
    func formatTimeFor(seconds: Double) -> String {
        let result = getHoursMinutesSecondsFrom(seconds: seconds)
        let hoursString = "\(result.hours)"
        var minutesString = "\(result.minutes)"
        if minutesString.characters.count == 1 {
            minutesString = "0\(result.minutes)"
        }
        var secondsString = "\(result.seconds)"
        if secondsString.characters.count == 1 {
            secondsString = "0\(result.seconds)"
        }
        var time = "\(hoursString):"
        if result.hours >= 1 {
            time.append("\(minutesString):\(secondsString)")
        }
        else {
            time = "\(minutesString):\(secondsString)"
        }
        return time
    }


}
extension UIViewController
{
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    func removeTapGesture(){
        for recognizer in view.gestureRecognizers ?? [] {
            view.removeGestureRecognizer(recognizer)
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}
extension UIDevice {
    var iPhone: Bool {
        return UIDevice().userInterfaceIdiom == .phone
    }
    enum ScreenType: String {
        case iPhone4
        case iPhone5
        case iPhone6
        case iPhone6Plus
        case unknown
    }
    var screenType: ScreenType {
        guard iPhone else { return .unknown }
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhone4
        case 1136:
            return .iPhone5
        case 1334:
            return .iPhone6
        case 2208:
            return .iPhone6Plus
            
        default:
            return .unknown
        }
        
    }

    
}
struct ScreenSize
{
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6_7          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P_7P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
    static let IS_IPAD_PRO          = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1366.0
}
