//
//  TabbarManagerVC.swift
//  SentirLite
//
//  Created by Hung Nguyen on 7/26/17.
//  Copyright © 2017 Skylab. All rights reserved.
//

import UIKit
import GoogleMobileAds
import AVFoundation

enum DisplayScreen: String {
    
    case Setting    = "SettingNC"
    
    case LiveView   = "LiveViewNC"
    
    case Storage    = "StorageNC"
    
    case Camera     = "CameraNC"

}
class TabbarManagerVC: BaseVC , GADBannerViewDelegate {

    @IBOutlet weak var liveViewTitleBtn: UILabel!
    
    @IBOutlet weak var storageTitleBtn: UILabel!
    
    @IBOutlet weak var settingTitleBtn: UILabel!
    
    @IBOutlet weak var cameraTitleBtn: UILabel!

    @IBOutlet weak var iconLiveImg: UIImageView!
    
    @IBOutlet weak var iconSettingImg: UIImageView!
    
    @IBOutlet weak var iconCameraImg: UIImageView!

    @IBOutlet weak var iconStorageImg: UIImageView!
    
    @IBOutlet weak var liveViewBtn: UIButton!
    
    @IBAction func addCamera(_ sender: Any) {
        if displayVC == .Camera {
            let newVC = AddCameraVC.newVC()
            newVC.modalPresentationStyle = .fullScreen
            self.navigationController?.present(newVC, animated: true, completion: nil)
        }
    }
    @IBOutlet weak var storageBtn: UIButton!
    
    @IBOutlet weak var settingBtn: UIButton!
    @IBOutlet weak var cameraBtn: UIButton!

    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var barButtonItemOutlet: UIBarButtonItem!
    
    var displayVC : DisplayScreen = .LiveView

    var liveViewNC : UINavigationController!
    
    var storageNC : UINavigationController!
    
    var settingNC : UINavigationController!
    
    var cameraNC : UINavigationController!

    var numberOfCamOnline: String = ""
    var adMobBannerView = GADBannerView()
    @IBAction func refreshData(_ sender: Any) {
        
        if displayVC == .Camera {
            self.confirmPopup(title: LocalizableKey.appName, subTitle: "Are you sure you want to log out?", yesAct: {
                NotificationCenter.default.post(name: kUserReLogin, object: nil)
//                self.userLogout()
            })
        } else if displayVC == .Storage || displayVC == .LiveView {
            NotificationCenter.default.post(name: kRefreshData, object: nil)
        }
    }
    @IBAction func changeTab(_ sender: UIButton) {
        
        if sender === liveViewBtn {

            if displayVC == .LiveView { return }
            
            displayMainView(nav: liveViewNC)
            
            displayVC = .LiveView
            
            updateLayoutTabbar(tabName: .LiveView)
            
            NotificationCenter.default.post(name: kUserDidChangeIndexTabPage, object: nil)
            
        } else if sender === storageBtn {
            
            if displayVC == .Storage { return }
            
            displayMainView(nav: storageNC)

            displayVC = .Storage
            
            updateLayoutTabbar(tabName: .Storage)
            
            NotificationCenter.default.post(name: kUserDidChangeIndexTabPage, object: nil)

            
        } else if sender === cameraBtn {
            
            if displayVC == .Camera { return }
            
            displayMainView(nav: cameraNC)
            
            displayVC = .Camera
            
            updateLayoutTabbar(tabName: .Camera)
            
            NotificationCenter.default.post(name: kUserDidChangeIndexTabPage, object: nil)
        } else if sender === settingBtn {
            
            if displayVC == .Setting { return }
            
            displayMainView(nav: settingNC)
            
            displayVC = .Setting
            
            updateLayoutTabbar(tabName: .Setting)
            
            NotificationCenter.default.post(name: kUserDidChangeIndexTabPage, object: nil)
        }
        
    }
    let ad = UIApplication.shared.delegate as! AppDelegate

    var CameraDS: CameraDataSource = CameraDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLocalizeString()
        checkLogin()
        initAdMobBanner()
        let mainStrBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        self.liveViewNC = mainStrBoard.instantiateViewController(withIdentifier: "LiveViewNC") as! UINavigationController
        
        self.storageNC = mainStrBoard.instantiateViewController(withIdentifier: "StorageNC") as? UINavigationController
        
        self.settingNC = mainStrBoard.instantiateViewController(withIdentifier: "SettingNC") as? UINavigationController
        self.cameraNC = mainStrBoard.instantiateViewController(withIdentifier: "ListMyCameraNC") as! UINavigationController

        displayMainView(nav: liveViewNC)
        observerNotification()
        updateLayoutTabbar(tabName: .LiveView)
        // Do any additional setup after loading the view.
    }
    func setUpLocalizeString() {
        self.liveViewTitleBtn.text           = NSLocalizedString("live_view", comment: "")
        self.storageTitleBtn.text            = NSLocalizedString("storage", comment: "")
        self.cameraTitleBtn.text = NSLocalizedString("camera", comment: "")
        self.settingTitleBtn.text = NSLocalizedString("setting", comment: "")
    }
 
    // MARK: -  ADMOB BANNER
    func initAdMobBanner() {
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            // iPhone
            adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSize(width: view.frame.size.width, height: 50))
            adMobBannerView.frame = CGRect(x: 0, y: view.frame.size.height, width: 320, height: 50)
        } else  {
            // iPad
            adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSize(width: 468, height: 50))
            adMobBannerView.frame = CGRect(x: 0, y: view.frame.size.height, width: 468, height: 50)
        }
        
        #if DEBUG
        adMobBannerView.adUnitID = "ca-app-pub-3940256099942544/6300978111"
        #else
        adMobBannerView.adUnitID = "ca-app-pub-9051606217608209/9208200057"
        #endif
        adMobBannerView.rootViewController = self
        adMobBannerView.delegate = self
        //view.addSubview(adMobBannerView)
        
        let request = GADRequest()
//        request.testDevices = [ kGADSimulatorID,    // All simulators
//            "6147f9a147eefa06cac7209762075532" ];  // Sample device ID
        
        adMobBannerView.load(request)
    }

    
    // Hide the banner
    func hideBanner(_ banner: UIView) {
        UIView.beginAnimations("hideBanner", context: nil)
        banner.frame = CGRect(x: view.frame.size.width/2 - banner.frame.size.width/2, y: view.frame.size.height - banner.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
        UIView.commitAnimations()
        banner.isHidden = true
    }
    
    // Show the banner
    func showBanner(_ banner: UIView) {
        UIView.beginAnimations("showBanner", context: nil)
        banner.frame = CGRect(x: view.frame.size.width/2 - banner.frame.size.width/2, y: view.frame.size.height - banner.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
        UIView.commitAnimations()
        banner.isHidden = false
    }
    
    // AdMob banner available
    func adViewDidReceiveAd(_ view: GADBannerView) {
      showBanner(adMobBannerView)
    }
    
    // NO AdMob banner available
    func adView(_ view: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        hideBanner(adMobBannerView)
    }

    func observerNotification(){
        NotificationCenter.default.addObserver(forName: kDismissView, object: nil, queue: nil) { [weak self] notif in
            
            guard let `self` = self else {return}
            self.navigationController?.dismiss(animated: true, completion: nil)

        }

     
        NotificationCenter.default.addObserver(forName: kUserReLogin, object: nil, queue: nil) { [weak self] notif in
            guard let `self` = self else {return}
            self.userLogout()
        }
        
        NotificationCenter.default.addObserver(forName: kUserDidLogin, object: nil, queue: nil) { [weak self] notif in
            
            guard let `self` = self else {return}
            
            self.displayMainView(nav: self.liveViewNC)
            self.displayVC = .LiveView
            self.updateLayoutTabbar(tabName: .LiveView)
            
        }
        
        NotificationCenter.default.addObserver(forName: kCountOnlineCamera, object: nil, queue: nil) { [weak self] notif in
            
            guard let `self` = self else {return}
            
            let statusString = notif.object as? String ?? ""
            self.numberOfCamOnline = statusString
            if self.displayVC == .LiveView {
                self.navigationController?.navigationBar.topItem?.leftBarButtonItem?.title = statusString

            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name("kUserDidSelectCamera"), object: nil, queue: nil) { [weak self] notif in
            guard let `self` = self else {return}
            
            var linkURLVideo = ""
            guard let camera = notif.object as? Camera else {return}

            let sessionKey = self.ad.logginUser?.sessionKey
            
            let headers: [String: String] = [
                
                "X-Tokens": sessionKey ?? ""
            ]

            self.CameraDS.getLinkVideo(cameraCode: camera.cameraCode, headers: headers, completion: { (linkVideo) in
                
                linkURLVideo = linkVideo
                
                let newVC = MediaPlayerVC.newVC()
                
                newVC.cameraCode = camera.cameraCode
                
                newVC.URLString = linkURLVideo
                newVC.modalPresentationStyle = .fullScreen
                self.present(newVC, animated: true, completion: nil)

                
            }) { (error) in
                if error.msg == "Session expired." || error.msg == "Incorrect session." {
                
                    NotificationCenter.default.post(name: kUserReLogin, object: nil)
                    
                }

            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name("ShowFullScreenStorageVideo"), object: nil, queue: nil) { [weak self] notif in
            guard let `self` = self else {return}
            guard let record = notif.object as? Record else {return}
            let newVC = StorageFullScreenVC.newVC()
            newVC.record = record
            newVC.player = VGPlayer(URL: URL(string: record.viewRecordUrl)!)
            newVC.modalPresentationStyle = .fullScreen
            self.present(newVC, animated: true, completion: nil)
        }
        
    }
    
    
    func displayMainView(nav:UIViewController) {
       
        if let lastNav = self.mainView.subviews.first {
       
            lastNav.removeFromSuperview()
       
        }
      
        self.mainView.addSubview(nav.view)
     
        nav.view.frame = self.mainView.bounds
      
        nav.view.autoresizingMask = [.flexibleHeight,.flexibleWidth]
      
        nav.didMove(toParent: self)
        
    }
    func checkLogin(){
        if !self.isLoggedIn() {
            let vc = LoginVC.newVC()
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func userLogout() {
        if var user = self.ad.logginUser {
            user.userInformation?.isLogin = false
            let userDict = user.toDict()
            UserDefaults.standard.set(userDict, forKey: "userDict")
            UserDefaults.standard.synchronize()
        }
        self.ad.logginUser = nil
        checkLogin()
    }
    
    
    func updateLayoutTabbar(tabName: DisplayScreen) {
        
        if tabName == .LiveView {
            self.navigationController?.navigationBar.topItem?.title = ad.logginUser?.userInformation?.name

            liveViewTitleBtn.textColor = COLOR.mainBlueColor
            
            storageTitleBtn.textColor = COLOR.mainGrayColor
            
            settingTitleBtn.textColor = COLOR.mainGrayColor
            
            cameraTitleBtn.textColor = COLOR.mainGrayColor

            iconLiveImg.image = UIImage(named: "IconLiveViewActive")
            
            iconSettingImg.image = UIImage(named: "IconSetting")
            
            iconCameraImg.image = UIImage(named: "iconCameraEmpty")

            iconStorageImg.image = UIImage(named: "IconStorage")
            
            barButtonItemOutlet.image = UIImage(named: "Shape")
            
            barButtonItemOutlet.title = " "
       
        } else if tabName == .Storage {
            
            self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("storage", comment: "Storage")

            liveViewTitleBtn.textColor = COLOR.mainGrayColor
            
            storageTitleBtn.textColor = COLOR.mainBlueColor
            
            settingTitleBtn.textColor = COLOR.mainGrayColor
            
            cameraTitleBtn.textColor = COLOR.mainGrayColor
            
            iconLiveImg.image = UIImage(named: "IconLiveView")
            
            iconSettingImg.image = UIImage(named: "IconSetting")
            
            iconCameraImg.image = UIImage(named: "iconCameraEmpty")
            
            iconStorageImg.image = UIImage(named: "IconStorageActive")
            
            barButtonItemOutlet.image = UIImage(named: "Shape")
            
            barButtonItemOutlet.title = " "
            
            self.navigationController?.navigationBar.topItem?.leftBarButtonItem?.title = self.numberOfCamOnline

            
        } else if tabName == .Camera && UserDefaults.standard.string(forKey: "panel") == "hide" {
            
            self.navigationController?.navigationBar.topItem?.title = "Camera"

            liveViewTitleBtn.textColor = COLOR.mainGrayColor
            
            storageTitleBtn.textColor = COLOR.mainGrayColor
            
            cameraTitleBtn.textColor = COLOR.mainBlueColor
            
            settingTitleBtn.textColor = COLOR.mainGrayColor
            
            iconLiveImg.image = UIImage(named: "IconLiveView")
            
            iconCameraImg.image = UIImage(named: "iconCameraFilled")
            
            iconSettingImg.image = UIImage(named: "IconSetting")

            iconStorageImg.image = UIImage(named: "IconStorage")
            
            barButtonItemOutlet.image = UIImage(named: "")
            
            barButtonItemOutlet.title = NSLocalizedString("log_out", comment: "")
            self.navigationController?.navigationBar.topItem?.leftBarButtonItem?.title = "Add Camera"

        }
        else if tabName == .Camera && UserDefaults.standard.string(forKey: "panel") == "show" {
            
            self.navigationController?.navigationBar.topItem?.title = "Camera"

            liveViewTitleBtn.textColor = COLOR.mainGrayColor
            
            storageTitleBtn.textColor = COLOR.mainGrayColor
            
            cameraTitleBtn.textColor = COLOR.mainBlueColor
            
            settingTitleBtn.textColor = COLOR.mainGrayColor
            
            iconLiveImg.image = UIImage(named: "IconLiveView")
            
            iconCameraImg.image = UIImage(named: "iconCameraFilled")
            
            iconSettingImg.image = UIImage(named: "IconSetting")

            iconStorageImg.image = UIImage(named: "IconStorage")
            
            barButtonItemOutlet.image = UIImage(named: "")
            barButtonItemOutlet.title = NSLocalizedString("log_out", comment: "")

        }
        else if tabName == .Setting {
            
            self.navigationController?.navigationBar.topItem?.title = "Setting"
            
            liveViewTitleBtn.textColor = COLOR.mainGrayColor
            
            storageTitleBtn.textColor = COLOR.mainGrayColor
            
            cameraTitleBtn.textColor = COLOR.mainGrayColor
            
            settingTitleBtn.textColor = COLOR.mainBlueColor
            
            iconLiveImg.image = UIImage(named: "IconLiveView")
            
            iconCameraImg.image = UIImage(named: "iconCameraEmpty")
            
            iconSettingImg.image = UIImage(named: "IconSettingActive")
            
            iconStorageImg.image = UIImage(named: "IconStorage")
            
            barButtonItemOutlet.image = UIImage(named: "")
            
            barButtonItemOutlet.title = NSLocalizedString(" ", comment: "")
            self.navigationController?.navigationBar.topItem?.leftBarButtonItem?.title = ""
            
        }
        
    }

}
