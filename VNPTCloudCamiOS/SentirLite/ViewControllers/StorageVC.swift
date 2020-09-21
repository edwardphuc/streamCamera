//
//  StorageVC.swift
//  SentirLite
//
//  Created by TuanNguyen on 7/26/17.
//  Copyright © 2017 Skylab. All rights reserved.
//

import UIKit
import Crashlytics
import Photos
import Alamofire
import PrecisionLevelSlider

import SVProgressHUD

class StorageVC: BaseVC, VGPlayerDelegate, VGPlayerViewDelegate, UIScrollViewDelegate {
    
//    @IBAction func playVideo(_ sender: Any) {
//    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bottomConstraintRulerView: NSLayoutConstraint!
    @IBOutlet weak var heightConstraintHeaderView: NSLayoutConstraint!
    
    @IBOutlet weak var timeSliderLb: UILabel!
    @IBOutlet weak var slider: PrecisionLevelSlider!
    @IBOutlet weak var selectCameraOutlet: UIButton!
    @IBOutlet weak var selectDateOutlet: UIButton!

    @IBAction func download(_ sender: Any) {
        
        if recordDidSelect == nil {
            errorPopup(title: "ALERT", subTitle: "Let's choose camera you want to play.", completion: nil)
            return
        }
        if let urlDownload = recordDidSelect?.recordFile {
            downloadVideoLinkAndCreateAsset(urlDownload)
        }
    }
    
    @IBOutlet weak var headerView: UIView!
    @IBAction func selectCameraBtn(_ sender: Any) {
        self.showFilterPopup(data: stateData, tittle: "DEFAULT",delegate: self)
    }
    @IBAction func selectDateBtn(_ sender: Any) {
        self.showCalendarPickerPopup(filterType: "Calendar", data: time, delegate: self)
    }
    let ad = UIApplication.shared.delegate as! AppDelegate
    var cameraDS: CameraDataSource = CameraDataSource()
    var stateData:[FilterItem] = []
    var listCamera: [Camera] = []
    var listRecord: [Record] = []
    var indexPath:IndexPath?
    var cameraCode :String = ""
    var isPlaying:Bool = false
    var time:DatePickerType = DatePickerType(dateString: "", date: Date(timeIntervalSince1970: Date.timeIntervalBetween1970AndReferenceDate + Date.timeIntervalSinceReferenceDate))
    var indexRecord = 0
    var isSelectedCamera :Bool = false
    var recordDidSelect: Record?
    var urlRecordSelected = ""
    var player: VGPlayer?
    var arrayTimeHasNoRecord: [Int] = []
    var oldRecord: Record?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectCameraOutlet.setTitle(NSLocalizedString("select_camera", comment: "Select Camera"), for: .normal)
        let dateStr = time.date.timeIntervalSince1970.format2String(format: "dd/MM/yy")
//        _ = self.time.date.timeIntervalSince1970.format2String(format: "MMM dd, YYYY")
        self.selectDateOutlet.setTitle(dateStr, for: .normal)
        self.observerList()
        getListCamera()

        if UIDevice().screenType == .iPhone5 {
            self.heightConstraintHeaderView.constant = 270
            self.bottomConstraintRulerView.constant = 10
        }
        self.player = VGPlayer()
        self.player?.delegate = self
        scrollView.delegate = self
        self.scrollView.addSubview(self.headerView)
//        self.scrollView.addSubview((player?.displayView)!)
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 5.0
        
        headerView.addSubview((player?.displayView)!)
        self.player?.displayView.titleLabel.isHidden = true
        self.player?.displayView.loadingIndicator.stopAnimating()
        self.player?.displayView.closeButton.isHidden = true
        self.player?.delegate = self
        self.player?.displayView.delegate = self
        self.player?.displayView.snp.makeConstraints { [weak self] (make) in
            guard let strongSelf = self else { return }
            make.top.equalTo(strongSelf.headerView.snp.top)
            make.left.equalTo(strongSelf.headerView.snp.left)
            make.right.equalTo(strongSelf.headerView.snp.right)
            make.height.equalTo(strongSelf.headerView.snp.width).multipliedBy(3.0/4.0) // you can 9.0/16.0
        }
        self.player?.backgroundMode = .suspend
        self.slider.addTarget(self, action: #selector(sliderValueChanged(slider:)), for: .valueChanged)
        if let oldRrd = oldRecord {
            replayVideo(record: oldRrd)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return self.headerView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        print("detected zoom")
    }
    
    /// fullscreen
    func vgPlayerView(_ playerView: VGPlayerView, willFullscreen fullscreen: Bool) {

        if recordDidSelect != nil {
//            player?.stopPlayerBuffering()
            NotificationCenter.default.post(name: Notification.Name("ShowFullScreenStorageVideo"), object: recordDidSelect)

        }
        
    }

    
    func observerList() {
        
        NotificationCenter.default.addObserver(forName: kVideoDidHaveAProblem, object: nil, queue: nil) { [weak self] notif in
            guard let `self` = self else {return}
            
            self.errorPopup(title: LocalizableKey.appName, subTitle: NSLocalizedString("kVideoDidHaveAPromblem", comment: ""), completion: nil )
            
        }
        
        NotificationCenter.default.addObserver(forName: kUserDidLogin, object: nil, queue: nil) { [weak self] notif in
            guard let `self` = self else {return}
            self.getListCamera()
        }
        
        NotificationCenter.default.addObserver(forName: kRefreshData, object: nil, queue: nil) { [weak self] notif in
            guard let `self` = self else {return}
            if self.isLoggedIn() {
                self.getListCamera()
                self.player?.pause()
            }
        }
        
        NotificationCenter.default.addObserver(forName: kUserDidChangeIndexTabPage, object: nil, queue: nil) { [weak self] notif in
            guard let `self` = self else {return}
            self.hideLoading(delay: 0)
            self.player?.pause()
        }
    }
    
    func createRuler() {
        self.slider.arrayNoRecord = arrayTimeHasNoRecord
        self.slider.longNotchColor = UIColor.blue
        self.slider.shortNotchColor = UIColor.blue
        self.slider.minimumValue = 0
        self.slider.maximumValue = 24
        self.slider.value = 0
        self.slider.isContinuous = false
        self.slider.addTarget(self, action: #selector(sliderValueChanged(slider:)), for: .valueChanged)
    }
    
    @objc func sliderValueChanged(slider: PrecisionLevelSlider) {

        let hourMark = Float(slider.value)
        let secondMark = Int(hourMark * 3600)

        timeSliderLb.text = formatTimeFor(seconds: Double(secondMark))

        if listRecord.isEmpty && isSelectedCamera {
            errorPopup(title: "ALERT", subTitle: "Has no record video. Let's select others date", completion: nil)
            return
        } else if listRecord.isEmpty && !isSelectedCamera {
            errorPopup(title: "ALERT", subTitle: "Let's choose camera you want to play.", completion: nil)
            return
        }
//        let todayString =  Date().timeIntervalSince1970.format2String(format: "YYYYMMdd")
//        let time = self.time.date.timeIntervalSince1970.format2String(format: "YYYYMMdd")
//        var lastTime = 0
//        if Int(time)! < Int(todayString)! {
//            lastTime = listRecord.last?.secondEnd ?? 0
//            if secondMark > lastTime {
//                errorPopup(title: "ALERT", subTitle: "Has no record video at this time.", completion: nil)
//                return
//            }
//        } else {
//            lastTime = listRecord.first?.secondEnd ?? 0
//            if secondMark > lastTime {
//                errorPopup(title: "ALERT", subTitle: "Has no record video at this time.", completion: nil)
//                return
//            }
//        }
        
       
        indexRecord = 0
        for record in listRecord {

            if secondMark >= record.secondStart && secondMark <= record.secondEnd {
                recordDidSelect = record
                if recordDidSelect != nil {
                    let timeNeedToSeek = Double(secondMark - record.secondStart)
                    recordDidSelect?.seekToTime = timeNeedToSeek
                    playVideo(record: recordDidSelect!)
                    break
                }
            }
            indexRecord += 1
        }
   
    }
    func playVideo(record: Record) {
        oldRecord = record
        self.player?.replaceVideo(URL(string: record.viewRecordUrl)!)
        self.player?.play()
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
            if record.seekToTime != nil && self.player?.playerItem?.status == .readyToPlay {
                let cmTime = CMTimeMake(value: Int64(record.seekToTime!), timescale: 1)
                self.player?.playerItem?.seek(to: cmTime, completionHandler: { (finished) in
                })
            }
        }
    }
    
    func replayVideo(record: Record) {
        self.player?.replaceVideo(URL(string: record.viewRecordUrl)!)
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
            if record.seekToTime != nil && self.player?.playerItem?.status == .readyToPlay {
                let cmTime = CMTimeMake(value: Int64(record.seekToTime!), timescale: 1)
                self.player?.playerItem?.seek(to: cmTime, completionHandler: { (finished) in
                })
            }
        }
    }
    
    func vgPlayer(_ player: VGPlayer, stateDidChange state: VGPlayerState) {
        if state == .playFinished {
            let record = self.listRecord[indexRecord-1]
            playVideo(record: record)
            indexRecord-=1
            let newSliderValue = Float(Double(record.secondStart)/3600)
            slider.value = newSliderValue
            timeSliderLb.text = formatTimeFor(seconds: Double(record.secondStart))
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        restrictRotation(false)
    }
    
    func restrictRotation(_ restriction: Bool) {
        let appDelegate: AppDelegate? = (UIApplication.shared.delegate as? AppDelegate)
        appDelegate?.restrictRotation = restriction
    }
    
    func getListCamera() {
        let sessionKey = ad.logginUser?.sessionKey
        let headers: [String: String] = [
            "X-Tokens": sessionKey ?? ""
        ]
        cameraDS.getListCamera(headers: headers, completion: { (camList) in
            self.stateData.removeAll()
            self.listCamera.removeAll()
            for cam in camList {
                let item = FilterItem(name: cam.cameraName, isSelected: false, cameraCode: cam.cameraCode)
                self.stateData.append(item)
            }
            self.listCamera = camList
            
        }) { (error) in
            
            if error.msg.range(of: "Cannot connect server, please change URL !") != nil {
                
                self.errorPopup(title: error.code, subTitle: error.msg, completion: nil)
                
            } else if error.msg == "Session expired." || error.msg == "Incorrect session." {
                NotificationCenter.default.post(name: kUserReLogin, object: nil)
                
            } else {
                self.errorPopup(title: error.code, subTitle: error.msg, completion: nil)
            }
        }
    }
    
    func getListCameraRecord(cameraCode:String,time:String) {
        let sessionKey = ad.logginUser?.sessionKey
        let headers: [String: String] = [
            
            "X-Tokens": sessionKey ?? ""
        ]
        cameraDS.getListCameraRecord(headers: headers, cameraCode: cameraCode, time: time, completion: { (recordList) in
            self.listRecord.removeAll()
            self.listRecord = recordList
            if self.listRecord.isEmpty {
                self.player?.cleanPlayer()
                self.arrayTimeHasNoRecord = [Int](0...145)
                self.createRuler()
                return
            }
            self.arrayTimeHasNoRecord.removeAll()
            let todayString =  Date().timeIntervalSince1970.format2String(format: "YYYYMMdd")
            
            if Int(time)! < Int(todayString)! {
                guard let lastSecond = self.listRecord.first?.secondStart else {return}
                guard let firstSecond = self.listRecord.last?.secondStart else {return}
                let firstTime = Int((Double(firstSecond)/3600) * 6) + 1
                let lastTime = Int((Double(lastSecond)/3600) * 6) - 1
                if !(lastTime <= 0){
                    self.arrayTimeHasNoRecord = [Int](0...firstTime)
                }
                self.arrayTimeHasNoRecord += [Int](lastTime...145)
            } else {
                guard let lastSecond = self.listRecord.last?.secondStart else {return}
                guard let firstSecond = self.listRecord.first?.secondEnd else {return}
                let firstTime = Int((Double(firstSecond)/3600) * 6) + 1
                let lastTime = Int((Double(lastSecond)/3600) * 6) - 1
                if !(lastTime <= 0){
                    self.arrayTimeHasNoRecord = [Int](0...lastTime)
                }
                self.arrayTimeHasNoRecord += [Int](firstTime...145)
            }

            
            self.createRuler()
            
            DispatchQueue.global().async {
                for (index, record) in self.listRecord.enumerated() {
                    
                    let newIndex = index + 1
                    if newIndex == self.listRecord.count {return}
                    
                    let result =  Int(record.startTime)! - Int(self.listRecord[newIndex].endTime)!
                    
                    if result > 600 {
                        let firstNotch = Int(((Double(record.startTime)!/3600)*6) + 1)
                        let lastNotch = Int(((Double(record.startTime)!/3600)*6 + 1))
                        let newArray = [Int](firstNotch...lastNotch)
                        self.arrayTimeHasNoRecord += newArray
                        self.createRuler()
                    }
                }
            }
            
        }) { (error) in
            
            print(error)
            
            if error.msg.range(of: "Cannot connect server, please change URL !") != nil {
                
                self.errorPopup(title: error.code, subTitle: error.msg, completion: nil)
                
            } else if error.msg == "Session expired." || error.msg == "Incorrect session." {
                NotificationCenter.default.post(name: kUserReLogin, object: nil)
                
            } else {
                self.errorPopup(title: error.code, subTitle: error.msg, completion: nil)
            }
        }
    }
}


extension StorageVC {

    func downloadVideoLinkAndCreateAsset(_ videoLink: String) {
        
        // use guard to make sure you have a valid url
        guard let videoURL = URL(string: videoLink) else {
            self.hideLoading(delay: 0)
            return
        }
        
        self.showLoading()
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: OperationQueue.main)
        // set up your download task
        
        let downloadTask = session.downloadTask(with: videoURL)
        downloadTask.resume()
        
//        _  = session.downloadTask(with: videoURL) { (location, response, error) -> Void in
//            let statuscode = (response as! HTTPURLResponse).statusCode
//
//
//            // use guard to unwrap your optional url
//            guard let location = location else { return }
//
//            // create a deatination url with the server response suggested file name
//            let cAstr = "\(CACurrentMediaTime())"
//
//
//            let fileNameStr = cAstr.replacingOccurrences(of: ".", with: "0")
//
//            let destinationURL = documentsDirectoryURL.appendingPathComponent("\(fileNameStr).\(videoURL.lastPathComponent)")
//            print(destinationURL)
//            do {
//
//                try FileManager.default.moveItem(at: location, to: destinationURL)
//
//                PHPhotoLibrary.requestAuthorization({ (authorizationStatus: PHAuthorizationStatus) -> Void in
//
//                    // check if user authorized access photos for your app
//                    if authorizationStatus == .authorized {
//                        PHPhotoLibrary.shared().performChanges({
//                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: destinationURL)}) { completed, error in
//                                if completed {
//
//                                    print("Video asset created")
//                                    self.hideLoading(delay: 0)
//                                    DispatchQueue.main.async {
//
//                                        self.errorPopup(title: LocalizableKey.appName, subTitle: NSLocalizedString("video_downloaded", comment: ""), completion: nil)
//                                    }
//                                } else {
//                                    self.hideLoading(delay: 0)
//                                    print(error?.localizedDescription)
//                                    DispatchQueue.main.async {
//                                        let errCode = "error \(statuscode)"
//
//                                        self.errorPopup(title: errCode, subTitle: NSLocalizedString("video_canot_downloaded", comment: ""), completion: nil)
//                                    }
//
//                                }
//                            }
//                    }
//                })
//
//            } catch let error as NSError {
//                self.hideLoading(delay: 0)
//                DispatchQueue.main.async {
//                    self.errorPopup(title: LocalizableKey.appName, subTitle: NSLocalizedString("video_canot_downloaded", comment: ""), completion: nil)
//                }
//                print(error.localizedDescription)}
//
//            }.resume()
    }
    
}


extension StorageVC : URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        SVProgressHUD.dismiss()
        print("Finished downloading to \(location).")
    let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    guard let videoURL = URL(string: recordDidSelect?.recordFile ?? "") else {
        return
    }
    let cAstr = "\(CACurrentMediaTime())"
    let fileNameStr = cAstr.replacingOccurrences(of: ".", with: "0")
    let destinationURL = documentsDirectoryURL.appendingPathComponent("\(fileNameStr).\(videoURL.lastPathComponent)")
    print(destinationURL)
    do {

        try FileManager.default.moveItem(at: location, to: destinationURL)

        PHPhotoLibrary.requestAuthorization({ (authorizationStatus: PHAuthorizationStatus) -> Void in
            // check if user authorized access photos for your app
            if authorizationStatus == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: destinationURL)}) { completed, error in
                        if completed {
                            print("Video asset created")
                            self.hideLoading(delay: 0)
                            DispatchQueue.main.async {
                                self.errorPopup(title: LocalizableKey.appName, subTitle: NSLocalizedString("video_downloaded", comment: ""), completion: nil)
                            }
                        } else {
                            self.hideLoading(delay: 0)
                            print(error?.localizedDescription)
                        }
                    }
            }
        })
        } catch let error as NSError {
            self.hideLoading(delay: 0)
            DispatchQueue.main.async {
                self.errorPopup(title: LocalizableKey.appName, subTitle: NSLocalizedString("video_canot_downloaded", comment: ""), completion: nil)
            }
            print(error.localizedDescription)}
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
        SVProgressHUD.showProgress(progress)

    }
}

extension StorageVC: URLSessionTaskDelegate, URLSessionDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        print(downloadTask)
        print(fileOffset)
    }
    
    
}
extension StorageVC:PopUpVCDelegate {
    
    func chooseFilter(FilterPopUpVC popUpVC: FilterPopUpVC, items: [FilterItem]) {
        
        if popUpVC.tittlePopup == "DEFAULT" {
            isSelectedCamera = true
            self.stateData = items
            
            let selectedItems = self.stateData.filter { (item) -> Bool in
                return item.isSelected
            }
            
            
            if let firstItem = selectedItems.first {
                self.selectCameraOutlet.setTitle(firstItem.name, for: .normal)
                self.cameraCode = firstItem.cameraCode
                
                let time = self.time.date.timeIntervalSince1970.format2String(format: "YYYYMMdd")
                getListCameraRecord(cameraCode: self.cameraCode, time: time)
                
            } else {
                self.selectCameraOutlet.setTitle("DEFAULT", for: .normal)
            }
            
            
        }
        
        popUpVC.dismiss(animated: true, completion: nil)
    }
    
    
}
extension StorageVC:CalendarPickerVCDelegate {
    func UserChooseDate(CalendarPickerVC: CalendarPickerVC, date: DatePickerType, filterTypeStrr: String) {
        self.time = date
        let dateStr = date.date.timeIntervalSince1970.format2String(format: "dd/MM/yy")
        self.selectDateOutlet.setTitle(dateStr, for: .normal)
        
        let time = self.time.date.timeIntervalSince1970.format2String(format: "YYYYMMdd")
        if self.cameraCode == "" {
            print("please choose camera ")
        } else {
            getListCameraRecord(cameraCode: self.cameraCode, time: time)
        }
        
        CalendarPickerVC.dismiss(animated: true, completion: nil)
        
    }
}

