////
////  FullScreenPlayerVC.swift
////  SentirLite
////
////  Created by TuanNguyen on 7/28/17.
////  Copyright © 2017 Skylab. All rights reserved.
////
//
//import UIKit
//import AVFoundation
//
//class FullScreenPlayerVC: BaseVC,UIScrollViewDelegate {
//
//    static let identifier = "FullScreenPlayerVC"
//    class func newVC() ->  FullScreenPlayerVC{
//        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
//        let vc = storyBoard.instantiateViewController(withIdentifier: identifier) as! FullScreenPlayerVC
//        return vc
//    }
//    @IBOutlet weak var startTimeLbl: UILabel!
//    @IBOutlet weak var endTimeLbl: UILabel!
//    @IBOutlet weak var sliderOutlet: UISlider!
//    @IBOutlet weak var playerView: UIView!
//    @IBOutlet weak var scrollView: UIScrollView!
//    @IBOutlet weak var playerControlView: UIView!
//
//    @IBAction func dismissBtn(_ sender: Any) {
//        self.dismiss(animated: false) {
//            self.avPlayer?.pause()
//            NotificationCenter.default.post(name: kUserDidExitFullScreen, object: self.avPlayer?.currentTime())
//        }
//    }
//
//    var largeImageView:   UIImageView?
//
//    var recordFile: Record?
//
//    var cmTime: CMTime?
//
//    weak var avPlayer: AVPlayer?
//
//    var isPlayBtnIsHiden: Bool = false
//
//    var videoLayer = AVPlayerLayer()
//
//    let playBtn = UIButton(frame: CGRect(x: 100, y: 100, width: 50, height: 50))
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//
//        NotificationCenter.default.addObserver(self, selector: #selector(FullScreenPlayerVC.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
//
//        //Add tap gesture to movieView for play/pause
//
//        let gesture = UITapGestureRecognizer(target: self, action: #selector(MediaPlayerVC.movieViewTapped(_:)))
//        //
//        self.playerView.addGestureRecognizer(gesture)
//
//        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
//
//        doubleTap.numberOfTapsRequired = 2
//
//        view.addGestureRecognizer(doubleTap)
//
//
//        scrollView.delegate = self
//
//        self.avPlayer?.actionAtItemEnd = .none
//
//        self.scrollView.minimumZoomScale = 1.0
//
//        self.scrollView.maximumZoomScale = 5.0
//
//        self.scrollView.addSubview(self.playerView)
//
//        self.playerView.layer.addSublayer(videoLayer)
//
//        self.playBtn.isHidden = true
//
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(true)
//        restrictRotation(false)
//
//    }
//
//    func doubleTapped() {
//
//        self.scrollView.zoomScale = 1.0
//    }
//
//    func play(record:Record, time:CMTime) {
//
//        self.recordFile = record
//
//        self.cmTime = time
//
//        if let play = self.avPlayer {
//
//            play.pause()
//            avPlayer = nil
//        }
//
//        guard let videoUrl = URL(string: record.viewRecordUrl )  else {return}
//
//        self.avPlayer = AVPlayer()
//
//        videoLayer = AVPlayerLayer(player: self.avPlayer)
//
//        self.videoLayer.removeFromSuperlayer()
//
//        self.avPlayer = AVPlayer(url: videoUrl)
//
//        videoLayer = AVPlayerLayer(player: self.avPlayer)
//
//        videoLayer.frame = self.playerView.bounds
//
//        videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
//
//        self.playerView.layer.addSublayer(videoLayer)
//
//        self.playBtn.setImage(UIImage.init(named: "IconPause3"), for: .normal)
//
//        self.playBtn.addTarget(self, action: #selector(self.playVideo), for: .touchUpInside)
//
//        self.playBtn.translatesAutoresizingMaskIntoConstraints = false
//
//        self.view.addSubview(playBtn)
//
//        self.setConstraint()
//
//        guard let duration : CMTime = self.avPlayer?.currentItem?.asset.duration else {return}
//
//        let seconds : Float64 = CMTimeGetSeconds(duration)
//
//        self.endTimeLbl.text = self.formatTimeFor(seconds: Double(seconds))
//
//        self.avPlayer?.play()
//
//        self.avPlayer?.seek(to: time)
//
//        self.sliderOutlet.minimumValue = 0
//
//        self.sliderOutlet.maximumValue = Float(seconds)
//
//        self.sliderOutlet.isContinuous = false
//
//        self.sliderOutlet?.addTarget(self, action: #selector(self.playbackSliderValueChanged(_:)), for: .valueChanged)
//
//        self.avPlayer?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, 1), queue: DispatchQueue.main) { (CMTime) -> Void in
//
//            if self.avPlayer?.currentItem?.status == .readyToPlay {
//
//                let time : Float64 = CMTimeGetSeconds(self.avPlayer!.currentTime())
//                self.sliderOutlet.value = Float ( time )
//
//                self.startTimeLbl.text = self.formatTimeFor(seconds: Double(time))
//
//                if self.sliderOutlet.value == self.sliderOutlet.maximumValue {
//                    self.avPlayer?.pause()
//                }
//            }
//        }
//    }
//
//
//    func playbackSliderValueChanged(_ playbackSlider:UISlider) {
//
//        let seconds : Int64 = Int64(self.sliderOutlet.value)
//
//        let targetTime:CMTime = CMTimeMake(seconds, 1)
//
//        self.avPlayer?.seek(to: targetTime)
//
//        if self.avPlayer?.rate == 0
//        {
//            self.avPlayer?.play()
//
//        } else {
//
//            self.avPlayer?.pause()
//        }
//
//    }
//
//    func restrictRotation(_ restriction: Bool) {
//        let appDelegate: AppDelegate? = (UIApplication.shared.delegate as? AppDelegate)
//        appDelegate?.restrictRotation = restriction
//    }
//
//    func rotated() {
//
//        let orientation = UIDevice.current.orientation
//
//        if (UIDeviceOrientationIsLandscape(orientation)) {
//
//            print("Switched to landscape")
//
//        } else if(UIDeviceOrientationIsPortrait(orientation)) {
//
//            print("Switched to portrait")
//
//        }
//
//        playerView.frame = self.view.frame
//
//        videoLayer.frame = playerView.frame
//
//    }
//
//    func setConstraint() {
//
//        NSLayoutConstraint(item: playBtn, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0).isActive = true
//
//        NSLayoutConstraint(item: playBtn, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0).isActive = true
//
//        NSLayoutConstraint(item: playBtn, attribute: NSLayoutAttribute.height, relatedBy: .equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 55).isActive = true
//
//        NSLayoutConstraint(item: playBtn, attribute: NSLayoutAttribute.width, relatedBy: .equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 55).isActive = true
//
//    }
//
//    func playVideo(sender: UIButton!) {
//
//        if self.avPlayer?.rate == 0 {
//            self.avPlayer?.play()
//            playBtn.setImage(UIImage.init(named: "IconPause3"), for: .normal)
//
//        } else {
//            self.avPlayer?.pause()
//            playBtn.setImage(UIImage.init(named: "IconPlay3"), for: .normal)
//
//        }
//
//    }
//
//
//
//
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        return self.playerView
//    }
//
//    func movieViewTapped(_ sender: UITapGestureRecognizer) {
//
//        if playBtn.isHidden == true {
//            UIView.animate(withDuration: 0.2, animations: {
//                self.playBtn.isHidden = false
//            })
//
//        } else {
//            UIView.animate(withDuration: 0.2, animations: {
//                self.playBtn.isHidden = true
//            })
//        }
//
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//}
//extension FullScreenPlayerVC : ZoomTransitionDestinationDelegate {
//
//    func transitionDestinationImageViewFrame(forward: Bool) -> CGRect {
//
//        if forward {
//            let x: CGFloat = 0.0
//            let y = topLayoutGuide.length
//            let width = view.frame.width
//            let height = width * 2.0 / 3.0
//            return CGRect(x: x, y: y, width: width, height: height)
//        } else {
//            return largeImageView!.convert(largeImageView!.bounds, to: view)
//        }
//    }
//
//    func transitionDestinationWillBegin() {
//        largeImageView?.isHidden = true
//    }
//
//    func transitionDestinationDidEnd(transitioningImageView imageView: UIImageView) {
//        largeImageView?.isHidden = false
//        largeImageView?.image = imageView.image
//    }
//
//    func transitionDestinationDidCancel() {
//        largeImageView?.isHidden = false
//    }
//
//}
