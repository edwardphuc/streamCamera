//
//  LiveViewVC.swift
//  SentirLite
//
//  Created by Hung Nguyen on 7/25/17.
//  Copyright © 2017 Skylab. All rights reserved.
//

import UIKit
import Alamofire

class LiveViewVC: BaseVC,VLCMediaPlayerDelegate {

    @IBOutlet weak var topConstraintOfCollectionView: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightViewControlPage: NSLayoutConstraint!
    @IBOutlet weak var constraintRightOfNextBtn: NSLayoutConstraint!
    @IBOutlet weak var constraintLeftOfPreviousBtn: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewControlPage: UIView!
    @IBOutlet weak var amountOfPage: UILabel!
    @IBOutlet weak var textLayoutLb: UILabel!
    @IBOutlet weak var gridViewLayoutBtn: UIButton!
    @IBOutlet weak var pageOneLayoutBtn: UIButton!
    @IBOutlet weak var pageFourLayoutBtn: UIButton!
    @IBOutlet weak var pageSixLayoutBtn: UIButton!
    //MARK: Previous Page
    @IBAction func previousPage(_ sender: Any) {
        goPreviousPage()
    }
    
    //MARK: Next Page
    @IBAction func nextPage(_ sender: Any) {
        goNextPage()
    }
    
    //MARK: Current tab is grid view
    @IBAction func changeGridLayout(_ sender: Any) {
        gridBtnTapped()
    }
    
    //MARK: Current tab is page view
    @IBAction func changePageLayout(_ sender: Any) {
        pageViewBtnTapped()
    }
    
    //MARK: Current tab is page 4 view
    
    @IBAction func changePageFourLayout(_ sender: Any) {
        fourViewBtnTapped()
    }
    
    //MARK: Current tab is page 6 view

    @IBAction func changePageSixLayout(_ sender: Any) {
        sixViewBtnTapped()
    }
    
    let ad = UIApplication.shared.delegate as! AppDelegate
    var listCamera: [Camera] = []
    var listCameraToDisplay : [Camera] = []
    var cameraDS : CameraDataSource = CameraDataSource()
    var gridLayout: GridLayout!
    var pageSixViewLayout : PageSixViewLayout!
    lazy var listLayout: PageLayout = {
        var listLayout = PageLayout(itemHeight: 265)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            listLayout = PageLayout(itemHeight: 500)
        }
        return listLayout
    }()
    
    var currentPageIndex: Int = 0
    
    var totalPage: Int = 0
    
    var styleLayoutID = ""
    
    var totalPage4View = 0
    
    var totalPage6View = 0
    
    var arrayCameraCode : [String] = []

    var statusDict: [String: String] = [:]
    
    var offlineCams: Int = 0
    
    var onlineCams: Int = 0
    
    var selectIndexDoubleTap = 3
    
    var currentPageIndexPage1Cam = 0
    
    var currentPageIndexPage4Cam = 0
    
    var currentPageIndexPage6Cam = 0

    var options: [Any] = ["--rtsp-tcp", "--no-drop-late-frames", "--no-skip-frames","--extraintf=", "--gain=0", "--rtsp-frame-buffer-size=10"]
    var sessionKey = ""

    lazy var mediaPlayer1 = VLCMediaPlayer()
    lazy var mediaPlayer2 = VLCMediaPlayer()
    lazy var mediaPlayer3 = VLCMediaPlayer()
    lazy var mediaPlayer4 = VLCMediaPlayer()
    lazy var mediaPlayer5 = VLCMediaPlayer()
    lazy var mediaPlayer6 = VLCMediaPlayer()


    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLocalizeString()
        restrictRotation(true)
        renderView()
        configCollectionView()
        observerNotification()
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(_:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        view.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft(_:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        view.addGestureRecognizer(swipeLeft)
        DispatchQueue.main.async {
            self.initAllPlayer()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.removeListCamera()
        restrictRotation(true)
        if isLoggedIn() {
            self.getListCamera()
            self.updateLayout()
        }

        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        if UIDevice.current.userInterfaceIdiom == .pad {
            topConstraintOfCollectionView.constant = 0
        }
    }

    
    override open var shouldAutorotate: Bool {
        return true
    }
    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }
    
    func gridBtnTapped() {
//        Thread.cancelPreviousPerformRequests(withTarget: self)
        deinitAllPlayer()

        if styleLayoutID == "grid" || self.listCamera.isEmpty {
            return
        } else {
            self.styleLayoutID = "grid"
        }
        currentPageIndex = 0
        self.listCameraToDisplay = listCamera
        UIView.animate(withDuration: 0.1, animations: {
            self.constraintHeightViewControlPage.constant = 0
            self.viewControlPage.isHidden = true
            self.collectionView.setCollectionViewLayout(self.gridLayout, animated: false)
        })
        DispatchQueue.main.async {
            self.updateLayout()
            self.collectionView.reloadData()
        }
    }
    func fourViewBtnTapped() {
//        Thread.cancelPreviousPerformRequests(withTarget: self)
        deinitAllPlayer()

        if self.listCamera.isEmpty || self.styleLayoutID == "page4"  {
            return
        } else {
            self.styleLayoutID = "page4"
        }
        showLoading()
        totalPage4View = listCamera.count % 4 == 0 ? listCamera.count / 4 : listCamera.count / 4 + 1
        self.amountOfPage.text = "\(currentPageIndexPage4Cam+1) / \(totalPage4View)"
        self.listCameraToDisplay = getListCameraToDisplay(currentPage: currentPageIndexPage4Cam, cameraNumber: 4)
        UIView.animate(withDuration: 0.1, animations: {
            self.constraintHeightViewControlPage.constant = 50
            self.viewControlPage.isHidden = false
            self.collectionView.setCollectionViewLayout(self.gridLayout, animated: false)
        })
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.updateLayout()
        }
    }
    
    func sixViewBtnTapped() {
//        Thread.cancelPreviousPerformRequests(withTarget: self)
        deinitAllPlayer()
        if  self.styleLayoutID == "page6" || self.listCamera.isEmpty {
            return
        } else {
            self.styleLayoutID = "page6"
        }
        showLoading()
        totalPage6View = listCamera.count % 6 == 0 ? listCamera.count / 6 : listCamera.count / 6 + 1
        self.amountOfPage.text = "\(currentPageIndexPage6Cam + 1) / \(totalPage6View) "
        self.listCameraToDisplay = getListCameraToDisplay(currentPage: currentPageIndexPage6Cam,cameraNumber: 6)
        UIView.animate(withDuration: 0.1, animations: {
            self.constraintHeightViewControlPage.constant = 50
            self.viewControlPage.isHidden = false
            self.pageSixViewLayout = PageSixViewLayout()
            self.collectionView.reloadData()
            self.collectionView.setCollectionViewLayout(self.pageSixViewLayout, animated: false)
        })
        DispatchQueue.main.async {
            self.updateLayout()
        }
    }
    func pageViewBtnTapped() {
        deinitAllPlayer()

        if self.listCamera.isEmpty || self.styleLayoutID == "page1" {
            return
        } else {
            self.styleLayoutID = "page1"
        }
        self.amountOfPage.text = "\(currentPageIndexPage1Cam + 1) / \(listCamera.count)"
        
        UIView.animate(withDuration: 0.1, animations: {
            self.listCameraToDisplay = self.getListCameraToDisplay(currentPage: self.currentPageIndexPage1Cam, cameraNumber: 1)
            self.constraintHeightViewControlPage.constant = 50
            self.viewControlPage.isHidden = false
        })
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.collectionView.setCollectionViewLayout(self.listLayout, animated: false)
            self.updateLayout()
        }
    }
    
    func goPreviousPage() {
//        Thread.cancelPreviousPerformRequests(withTarget: self)
        if self.listCamera.isEmpty {
            return
        }
        deinitAllPlayer()
        self.collectionView.slideInFromLeft()
        if styleLayoutID == "page1" {
            if currentPageIndexPage1Cam <= 0  {
                currentPageIndexPage1Cam = 0
                self.listCameraToDisplay = getListCameraToDisplay(currentPage: currentPageIndexPage1Cam, cameraNumber: 1)
                self.collectionView.reloadData()
                return
            }
            currentPageIndexPage1Cam -= 1
            self.listCameraToDisplay = getListCameraToDisplay(currentPage: currentPageIndexPage1Cam, cameraNumber: 1)
            self.amountOfPage.text = "\(currentPageIndexPage1Cam + 1) / \(listCamera.count)"
        } else if styleLayoutID == "page4" {
            if currentPageIndexPage4Cam <= 0 {
                currentPageIndexPage4Cam = 0
                return
            }
//            showLoading()
            currentPageIndexPage4Cam -= 1
            self.listCameraToDisplay = getListCameraToDisplay(currentPage: currentPageIndexPage4Cam, cameraNumber: 4)
            self.amountOfPage.text = "\(currentPageIndexPage4Cam + 1) / \(totalPage4View)"

        } else if styleLayoutID == "page6" {
            if currentPageIndexPage6Cam <= 0 {
                currentPageIndexPage6Cam = 0
                return
            }
//            showLoading()
            currentPageIndexPage6Cam -= 1
            self.listCameraToDisplay = getListCameraToDisplay(currentPage: currentPageIndexPage6Cam, cameraNumber: 6)
            self.amountOfPage.text = "\(currentPageIndexPage6Cam + 1) / \(totalPage6View)"
            
        }
        showLoading()
        self.collectionView.reloadData()
    }

    func goNextPage() {
//        Thread.cancelPreviousPerformRequests(withTarget: self)

        if self.listCamera.isEmpty {
            return
        }
        deinitAllPlayer()
        self.collectionView.slideInFromRight()

        if styleLayoutID == "page1" {
            currentPageIndexPage1Cam += 1
            if currentPageIndexPage1Cam > listCamera.count - 1 {
                currentPageIndexPage1Cam = self.listCamera.count - 1
                return
            }
            self.listCameraToDisplay = getListCameraToDisplay(currentPage: currentPageIndexPage1Cam, cameraNumber: 1)
            self.amountOfPage.text = "\(currentPageIndexPage1Cam + 1) / \(listCamera.count)"

        } else if styleLayoutID == "page4" {
            if currentPageIndexPage4Cam >= totalPage4View - 1 {
                return
            }
            currentPageIndexPage4Cam += 1
            self.listCameraToDisplay = getListCameraToDisplay(currentPage: currentPageIndexPage4Cam, cameraNumber: 4)
            self.amountOfPage.text = "\(currentPageIndexPage4Cam + 1) / \(totalPage4View)"

        } else if styleLayoutID == "page6" {
            if currentPageIndexPage6Cam >= totalPage6View - 1 {
                return
            }
//            showLoading()
            currentPageIndexPage6Cam += 1
            self.listCameraToDisplay = self.getListCameraToDisplay(currentPage: self.currentPageIndexPage6Cam, cameraNumber: 6)
            self.amountOfPage.text = "\(currentPageIndexPage6Cam + 1) / \(totalPage6View)"
            
        }
//        DispatchQueue.main.async {
            showLoading()
            self.collectionView.reloadData()
//        }
    }

    @objc func swipeLeft(_ gesture: UIGestureRecognizer) {
        if styleLayoutID == "grid"  { return }
        goNextPage()
    }

    @objc func swipeRight(_ gesture: UIGestureRecognizer) {
        if styleLayoutID == "grid"  { return }
        goPreviousPage()

    }
    
    func setUpLocalizeString() {
        self.textLayoutLb.text = NSLocalizedString("layout", comment: "")
    }
    
    func loadImageFromPath(path: String) -> UIImage? {
        let image = UIImage(contentsOfFile: path)
        return image
    }
    
    func restrictRotation(_ restriction: Bool) {
        let appDelegate: AppDelegate? = (UIApplication.shared.delegate as? AppDelegate)
        appDelegate?.restrictRotation = restriction
    }
    
    func updateLayout(){
        
        self.gridViewLayoutBtn.setImage(UIImage(named: "Grid"), for: .normal)
        self.pageOneLayoutBtn.setImage(UIImage(named: "PageOne"), for: .normal)
        self.pageFourLayoutBtn.setImage(UIImage(named: "PageFour"), for: .normal)
        self.pageSixLayoutBtn.setImage(UIImage(named: "PageSix"), for: .normal)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
        
            self.topConstraintOfCollectionView.constant = 0
            if styleLayoutID == "page1" {
                self.topConstraintOfCollectionView.constant = 100
            }
            
        } else if  UIDevice.current.userInterfaceIdiom == .phone {
            if styleLayoutID == "grid" {
                self.gridViewLayoutBtn.setImage(UIImage(named: "GridActive"), for: .normal)
                self.topConstraintOfCollectionView.constant = (self.view.frame.size.height / 2) - 275
                if UIDevice().screenType == .iPhone5 {
                    self.topConstraintOfCollectionView.constant = (self.view.frame.size.height / 2) - 230
                    
                }
                
            } else if styleLayoutID == "page1" {
                self.pageOneLayoutBtn.setImage(UIImage(named: "PageOneActive"), for: .normal)
                self.topConstraintOfCollectionView.constant = (self.view.frame.size.height / 2) - 190
                if UIDevice().screenType == .iPhone5 {
                    self.topConstraintOfCollectionView.constant = (self.view.frame.size.height / 2) - 170
                    
                }
                
            } else if styleLayoutID == "page4" {
                self.pageFourLayoutBtn.setImage(UIImage(named: "PageFourActive"), for: .normal)
                self.topConstraintOfCollectionView.constant = (self.view.frame.size.height / 2) - 240
                if UIDevice().screenType == .iPhone5 {
                    self.topConstraintOfCollectionView.constant = (self.view.frame.size.height / 2) - 200
                    
                }
                
            } else if styleLayoutID == "page6" {
                self.pageSixLayoutBtn.setImage(UIImage(named: "PageSixActive"), for: .normal)
                self.topConstraintOfCollectionView.constant = (self.view.frame.size.height / 2) - 240
                if UIDevice().screenType == .iPhone5 {
                    self.topConstraintOfCollectionView.constant = (self.view.frame.size.height / 2) - 200
                    
                }
            }
        }
      
    }
    
    func configCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: 10.0, left: 2.0, bottom: 10.0, right: 2.0)
        collectionView.collectionViewLayout = gridLayout
    }
    
    func removeListCamera() {
        self.listCamera.removeAll()
        self.listCameraToDisplay.removeAll()
    }
    
    func getListCameraToDisplay(currentPage: Int,cameraNumber: Int) -> [Camera] {
        var arrayCamera: [Camera] = []
        var temp = currentPage * cameraNumber
        for _ in 0...cameraNumber - 1 {
            
            if temp > self.listCamera.count - 1 {

                return arrayCamera
            }
            arrayCamera.append(self.listCamera[temp])
            
            temp += 1
            
        }
        return arrayCamera
    
    }
    
    func observerNotification() {
        
        NotificationCenter.default.addObserver(forName: kUserDidLogin, object: nil, queue: nil) { [weak self] notif in
            guard let `self` = self else {return}
            self.gridBtnTapped()
        }
        
        NotificationCenter.default.addObserver(forName: kRefreshData, object: nil, queue: nil) { [weak self] notif in
            guard let `self` = self else {return}
            if self.isLoggedIn() {
                self.showLoading()
                self.removeListCamera()
                self.currentPageIndexPage1Cam = 0
                self.currentPageIndexPage6Cam = 0
                self.currentPageIndexPage4Cam = 0
                self.getListCamera()
                self.hideLoading(delay: 1)
            }
        }
        
        NotificationCenter.default.addObserver(forName: kUserDidChangeIndexTabPage, object: nil, queue: nil) { [weak self] notif in
            guard let `self` = self else {return}
            self.hideLoading(delay: 0)
            self.deinitAllPlayer()
            self.collectionView.reloadData()
        }
    }
    
    func renderView() {
        self.styleLayoutID = "grid"
        gridLayout = GridLayout(numberOfColumns: 2)
        pageSixViewLayout = PageSixViewLayout(coder: .init())
        self.constraintHeightViewControlPage.constant = 0
        self.gridViewLayoutBtn.setImage(UIImage(named: "GridActive"), for: .normal)
        self.viewControlPage.isHidden = true
        if UIDevice().screenType == .iPhone5 {
            textLayoutLb.isHidden = true
            constraintRightOfNextBtn.constant = 25
            constraintLeftOfPreviousBtn.constant = 15
        }
    }
    
    func renderLayoutsCollectionView() {
        
        if self.styleLayoutID == "page6" {
            self.listCameraToDisplay = getListCameraToDisplay(currentPage: currentPageIndexPage6Cam, cameraNumber: 6)
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.setCollectionViewLayout(self.pageSixViewLayout, animated: false)
            self.amountOfPage.text = "\(currentPageIndexPage6Cam+1) / \(totalPage6View) "

            
        } else if self.styleLayoutID == "page4" {
            self.listCameraToDisplay = getListCameraToDisplay(currentPage: currentPageIndexPage4Cam, cameraNumber: 4)
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.setCollectionViewLayout(self.gridLayout, animated: false)
            self.amountOfPage.text = "\(currentPageIndexPage4Cam+1) / \(totalPage4View) "

        } else if self.styleLayoutID == "page1" {
            self.listCameraToDisplay = getListCameraToDisplay(currentPage: currentPageIndexPage1Cam, cameraNumber: 1)
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.setCollectionViewLayout(self.listLayout, animated: false)
            self.amountOfPage.text = "\(currentPageIndexPage1Cam+1) / \(listCamera.count) "

        } else if self.styleLayoutID == "grid" {
            self.listCameraToDisplay = listCamera
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.setCollectionViewLayout(self.gridLayout, animated: false)
        }

    }
    
    func getListCamera() {
        self.sessionKey = ad.logginUser?.sessionKey ?? ""
        let headers: [String: String] = [
            "X-Tokens": sessionKey
        ]
        cameraDS.getListCamera(headers: headers, completion: { (camList) in
            self.hideLoading(delay: 0)
            self.listCamera = camList
            self.listCameraToDisplay = self.listCamera

            DispatchQueue.main.async {
                self.renderLayoutsCollectionView()
            }
            self.checkStatusCamera()
            
        }) { (error) in
            if error.msg.range(of: "Cannot connect server, please change URL !") != nil {
                
                self.errorPopup(title: error.code , subTitle: error.msg, completion: nil)
                
            }else if error.msg == "Session expired." || error.msg == "Incorrect session." {
            NotificationCenter.default.post(name: kUserReLogin, object: nil)

            } else {
                self.errorPopup(title: error.code , subTitle: error.msg, completion: nil)

            }
        }
    }
    
    func checkStatusCamera() {
        self.sessionKey = ad.logginUser?.sessionKey ?? ""
        let headers: [String: String] = [
            "X-Tokens": sessionKey
        ]
        for item in self.listCamera {
            self.arrayCameraCode.append(item.cameraCode)
        }
        cameraDS.checkStatusCamera(parameters: arrayCameraCode, headers: headers,sessionKey: sessionKey, completion: { (result) in
            
            self.offlineCams = 0
            self.onlineCams = 0
            self.statusDict = result

            for (_, value) in self.statusDict {
                
                if value == "READY" {
                    self.onlineCams += 1
                } else {
                    self.offlineCams += 1
                }
            }
            let statusString = "Online: \(self.onlineCams)"
           
            NotificationCenter.default.post(name: kCountOnlineCamera, object: statusString)
            
            self.collectionView.reloadData()
            self.hideLoading(delay: 0)
            
        }) { (error) in
            self.hideLoading(delay: 0)
            print(error)
        }
    }
}
extension LiveViewVC : UICollectionViewDataSource,UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listCameraToDisplay.count
    }
    
    func getMedia(mediaPlayer: VLCMediaPlayer,media: VLCMedia, playerView: UIView, network: Int) {
        mediaPlayer.media = media
        mediaPlayer.media.addOptions(["network-caching": network])
        mediaPlayer.drawable =  playerView
        mediaPlayer.play()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! LiveViewCollectionViewCell
       
        let camera = listCameraToDisplay[indexPath.row]
        let myImage = "\(camera.cameraCode).png"
        let imagePath = fileInDocumentsDirectory(filename: myImage)
        sessionKey = ad.logginUser?.sessionKey ?? ""
        let headers: [String: String] = [
            "X-Tokens": self.sessionKey
        ]
        cell.fillData(data: camera)
        cell.cameraNameLb.text = camera.cameraName
        cell.cameraImage.image = self.loadImageFromPath(path: imagePath)

        if statusDict["\(camera.cameraCode)"] == "READY" {
            cell.iconPlayImg.image = UIImage(named: "IconPlay3")
            cell.statusCamera.text = " "
            cell.iconPlayImg.isHidden = false
            if self.styleLayoutID == "page4" || self.styleLayoutID == "page6" {
                cell.cameraImage.image = nil
                cell.cameraImage.isHidden = true
                cell.iconPlayImg.isHidden = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                if self.styleLayoutID == "page4" {
                    self.cameraDS.getLinkVideo(cameraCode: camera.cameraCode, headers: headers, completion: { (linkVideo) in
                        guard let url = URL(string: linkVideo) else {return}
                        let media = VLCMedia(url: url)
                        
                        if indexPath.item == 0 {
                            self.getMedia(mediaPlayer: self.mediaPlayer1, media: media, playerView: cell.playerView,network: 6000)
                            
                        } else if indexPath.item == 1 {

                            self.getMedia(mediaPlayer: self.mediaPlayer2, media: media, playerView: cell.playerView,network: 6000)
                        } else if indexPath.item == 2 {
                            
                            self.getMedia(mediaPlayer: self.mediaPlayer3, media: media, playerView: cell.playerView,network: 6000)
                        } else if indexPath.item == 3 {
                            
                            self.getMedia(mediaPlayer: self.mediaPlayer4, media: media, playerView: cell.playerView,network: 6000)
                        }
                        
                    }) { (error) in
                        self.hideLoading(delay: 0)
                    }
                    
                } else if self.styleLayoutID == "page6" {
                    self.cameraDS.getLinkVideo(cameraCode: camera.cameraCode, headers: headers, completion: { (linkVideo) in
                        guard let url = URL(string: linkVideo) else {return}
                        let media = VLCMedia(url: url)
                        if indexPath.item == 0 {
                            self.getMedia(mediaPlayer: self.mediaPlayer1, media: media, playerView: cell.playerView,network: 4000)
                            
                        } else if indexPath.item == 1 {
                            
                            self.getMedia(mediaPlayer: self.mediaPlayer2, media: media, playerView: cell.playerView,network: 4000)
                        } else if indexPath.item == 2 {
                            
                            self.getMedia(mediaPlayer: self.mediaPlayer3, media: media, playerView: cell.playerView,network: 4000)
                        } else if indexPath.item == 3 {
                            
                            self.getMedia(mediaPlayer: self.mediaPlayer4, media: media, playerView: cell.playerView,network: 4000)
                        } else if indexPath.item == 4 {
                            
                            self.getMedia(mediaPlayer: self.mediaPlayer5, media: media, playerView: cell.playerView,network: 4000)
                        }  else if indexPath.item == 5 {
                            
                            self.getMedia(mediaPlayer: self.mediaPlayer6, media: media, playerView: cell.playerView,network: 4000)
                        }
                        
                    }) { (error) in
                        self.hideLoading(delay: 0)
                    }
                }
            })
            

        } else {
            self.hideLoading(delay: 7)
            cell.statusCamera.text = NSLocalizedString("camera_is_not_available", comment: "")
            cell.iconPlayImg.isHidden = true
        }
        
        return cell
    }
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        if mediaPlayer1.isPlaying || mediaPlayer2.isPlaying || mediaPlayer3.isPlaying || mediaPlayer4.isPlaying || mediaPlayer5.isPlaying || mediaPlayer6.isPlaying {
            self.hideLoading(delay: 0)
        } else {
            self.hideLoading(delay: 10)
        }
        
    }
    
    func initAllPlayer() {
        mediaPlayer1 = VLCMediaPlayer(options: options)
        self.mediaPlayer1.delegate = self
        mediaPlayer2 = VLCMediaPlayer(options: options)
        self.mediaPlayer2.delegate = self
        mediaPlayer3 = VLCMediaPlayer(options: options)
        self.mediaPlayer3.delegate = self
        mediaPlayer4 = VLCMediaPlayer(options: options)
        self.mediaPlayer4.delegate = self
        mediaPlayer5 = VLCMediaPlayer(options: options)
        self.mediaPlayer5.delegate = self
        mediaPlayer6 = VLCMediaPlayer(options: options)
        self.mediaPlayer6.delegate = self
    }
    
    func deinitAllPlayer() {
        self.deinitPlayer(mediaPlayer: self.mediaPlayer1)
        self.deinitPlayer(mediaPlayer: self.mediaPlayer2)
        self.deinitPlayer(mediaPlayer: self.mediaPlayer3)
        self.deinitPlayer(mediaPlayer: self.mediaPlayer4)
        self.deinitPlayer(mediaPlayer: self.mediaPlayer5)
        self.deinitPlayer(mediaPlayer: self.mediaPlayer6)
        // End remote control events
//        UIApplication.shared.endReceivingRemoteControlEvents()
//        self.resignFirstResponder()
//        self.initAllPlayer()
    }
    
    func deinitPlayer(mediaPlayer: VLCMediaPlayer) {
        mediaPlayer.stop()
//        mediaPlayer.media = nil
//        mediaPlayer.delegate = nil
//        mediaPlayer.drawable = nil
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.deinitAllPlayer()
        }
        if ad.connectionManager?.networkReachabilityStatus == .notReachable {
            
            self.errorPopup(title: LocalizableKey.appName, subTitle: NSLocalizedString("no_internet_connection", comment: ""), completion: nil)
            
            ad.connectionManager = Alamofire.NetworkReachabilityManager(host: "www.google.com")
            return
        }
        let camera = listCameraToDisplay[indexPath.row]
        if statusDict["\(camera.cameraCode)"] != "READY" {
            self.errorPopup(title: "Vigilance Cloud Video", subTitle: NSLocalizedString("camera_is_not_available", comment: ""), completion: nil)
            return
        }

        if styleLayoutID == "page6" {
            
            if indexPath.row == 0 {
                NotificationCenter.default.post(name: Notification.Name("kUserDidSelectCamera"), object: listCameraToDisplay[indexPath.row])

            } else {
                listCameraToDisplay.rearrange(from: indexPath.row, to: 0)
                collectionView.reloadData()
            }
            
        } else {
            NotificationCenter.default.post(name: Notification.Name("kUserDidSelectCamera"), object: listCameraToDisplay[indexPath.row])

        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator:UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
}
