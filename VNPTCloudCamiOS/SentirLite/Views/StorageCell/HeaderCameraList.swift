//
//  HeaderCameraList.swift
//  SentirLite
//
//  Created by TuanNguyen on 7/26/17.
//  Copyright © 2017 Skylab. All rights reserved.
//

import UIKit
import AVFoundation


class HeaderCameraList: UIView,UIScrollViewDelegate {
    var recordFile:Record?
    weak var  avPlayer : AVPlayer?
    var isPlayBtnIsHiden:Bool = false
    
    var videoLayer = AVPlayerLayer()
    
    //    weak var delegate:CameraPlayerCellDelegate?
    let playBtn = UIButton(frame: CGRect(x: 100, y: 100, width: 50, height: 50))
    
    @IBOutlet weak var startTimeLbl: UILabel!
    @IBOutlet weak var endTimeLbl: UILabel!
    @IBOutlet weak var sliderOutlet: UISlider!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var heightPlayerConstrains: NSLayoutConstraint!
    @IBOutlet weak var playerControlView: UIView!
    
    @IBOutlet weak var startDateLbl: UILabel!
    @IBOutlet weak var flnishDateLbl: UILabel!
    @IBOutlet weak var saveDateLbl: UILabel!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "HeaderCameraList", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
        
    }
    
    @IBAction func fullScreenBtn(_ sender: Any) {
        
        if avPlayer == nil {return}
        let dict: [String:Any] = [
        
            "recordFile": self.recordFile,
            
            "cmTime": self.avPlayer!.currentTime()
        
        ]
        
        NotificationCenter.default.post(name: kUserDidTapFullScreen, object: dict)
    
        self.avPlayer?.pause()
    
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpLocalizeString()
        scrollView.delegate = self
//        self.heightPlayerConstrains.constant = 350
        self.playerControlView.isHidden = false
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(HeaderCameraList.movieViewTapped(_:)))

        self.playerView.addGestureRecognizer(gesture)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        
        doubleTap.numberOfTapsRequired = 2
        
        self.playerView.addGestureRecognizer(doubleTap)
        
        
        self.avPlayer?.actionAtItemEnd = .none
        
        self.scrollView.minimumZoomScale = 1.0
        
        self.scrollView.maximumZoomScale = 5.0
        
        self.scrollView.addSubview(self.playerView)
        
        self.playerView.layer.addSublayer(videoLayer)
        
        NotificationCenter.default.addObserver(forName: kUserDidExitFullScreen, object: nil, queue: nil) { [weak self] notif in
            guard let `self` = self else { return }
            if let time =  notif.object as? CMTime {
                self.avPlayer?.seek(to: time)
                self.avPlayer?.play()

            }
        }
        NotificationCenter.default.addObserver(forName: kPlayVideoPlayback, object: nil, queue: nil) { [weak self] notif in
            guard let `self` = self else { return }
            self.avPlayer?.play()
            self.playBtn.setImage(UIImage.init(named: "IconPause3"), for: .normal)
            self.playBtn.isHidden = true

        }
        
        NotificationCenter.default.addObserver(forName: kUserDidChangeIndexTabPage, object: nil, queue: nil) { [weak self] notif in
            guard let `self` = self else {return}
            self.avPlayer?.pause()
        }
        NotificationCenter.default.addObserver(forName: kPlayOrPausePlayer, object: nil, queue: nil) { [weak self] notif in
            guard let `self` = self else {return}
            self.playBtn.isHidden = !self.isPlayBtnIsHiden
            self.isPlayBtnIsHiden = !self.isPlayBtnIsHiden
            
        }
        NotificationCenter.default.addObserver(forName: kIsLoadingFalse, object: nil, queue: nil) { [weak self] notif in
            guard let `self` = self else {return}
            self.avPlayer?.pause()
            self.heightPlayerConstrains.constant = 0
            self.playerControlView.isHidden = true
        }

        
//        NotificationCenter.default.addObserver(forName: kUserDidSelectRecord, object: nil, queue: nil) { [weak self] notif in
//            guard let `self` = self else {return}
//            if let record = notif.object as? Record{
//                self.sliderOutlet.value = 0
//                self.playerView.frame = self.frame
//                self.recordFile = record
//                self.play(record: record)
//                let targetTime:CMTime = CMTimeMake(record.seekToTime!, 1)
//                self.avPlayer?.seek(to: targetTime)
//
//            }
//        }
        
        NotificationCenter.default.addObserver(forName: kUserDownLoadRecord, object: nil, queue: nil) { [weak self] notif in
            guard let `self` = self else {return}
            self.avPlayer?.pause()
        }
        
        NotificationCenter.default.addObserver(forName: kRefreshData, object: nil, queue: nil) {[weak self] notif in
            
            guard let `self` = self else {return}
            self.scrollView.zoomScale = 1
            self.avPlayer?.pause()
            self.sliderOutlet.value = 0

            let targetTime: CMTime = CMTimeMake(value: Int64(0.0), timescale: 1)
            
            self.avPlayer?.seek(to: targetTime)
            
            self.playBtn.setImage(UIImage.init(named: "IconPlay3"), for: .normal)
        }
        
    }

    @objc func doubleTapped() {
        
        self.scrollView.zoomScale = 1.0
    }
    func setUpLocalizeString() {
//        startDateLbl.text   = NSLocalizedString("start_date", comment: "")
//        flnishDateLbl.text  = NSLocalizedString("finish_date", comment: "")
//        saveDateLbl.text    = NSLocalizedString("save_date", comment: "")
    }
    
    func play(record:Record) {

        
        if let play = self.avPlayer {
            
            play.pause()
            
            avPlayer = nil
        }
        
        guard let videoUrl = URL(string: record.viewRecordUrl )  else {return}
        self.avPlayer = AVPlayer()
        videoLayer = AVPlayerLayer(player: self.avPlayer)
        self.videoLayer.removeFromSuperlayer()
        
        print(videoUrl)
        self.avPlayer = AVPlayer(url: videoUrl)
        
        
        videoLayer = AVPlayerLayer(player: self.avPlayer)
        
        videoLayer.frame = self.playerView.bounds
        
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        self.playerView.layer.addSublayer(videoLayer)
        
        self.playBtn.setImage(UIImage.init(named: "IconPlay3"), for: .normal)
        
        self.playBtn.addTarget(self, action: #selector(self.playVideo), for: .touchUpInside)
        
        self.playBtn.translatesAutoresizingMaskIntoConstraints = false
        
        self.playerView.addSubview(self.playBtn)
        
        self.setConstraint()
        
        guard let duration : CMTime = self.avPlayer?.currentItem?.asset.duration else {return}
        let seconds : Float64 = CMTimeGetSeconds(duration)
        // ko co video
        if seconds == 0.0 {
            NotificationCenter.default.post(name: HideLoading, object: nil)

            NotificationCenter.default.post(name: kVideoDidHaveAProblem, object: nil)
            return
        }
        
        self.endTimeLbl.text = self.formatTimeFor(seconds: Double(seconds))
        
        
//        self.avPlayer?.play()
        
        self.sliderOutlet.minimumValue = 0
        
        
        self.sliderOutlet.maximumValue = Float(seconds)
        self.sliderOutlet.isContinuous = false
        
        self.sliderOutlet?.addTarget(self, action: #selector(self.playbackSliderValueChanged(_:)), for: .valueChanged)
        
        weak var player = self.avPlayer
        
        player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            
            guard let player = player else {return}
            
            if player.currentItem?.status == .readyToPlay {
                let time : Float64 = CMTimeGetSeconds(player.currentTime())
                print(time)
                self.sliderOutlet.value = Float ( time )
                
                
                self.startTimeLbl.text = self.formatTimeFor(seconds: Double(time))
                
                if self.sliderOutlet.value == self.sliderOutlet.maximumValue {
                    player.pause()
                }
            }
            
        }
        NotificationCenter.default.post(name: HideLoading, object: nil)
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            print("Change at keyPath = \(keyPath) for \(self.avPlayer?.status.rawValue)")
        }
    }
    @objc func playbackSliderValueChanged(_ playbackSlider:UISlider) {
        let seconds : Int64 = Int64(self.sliderOutlet.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        
        self.avPlayer?.seek(to: targetTime)
        
        if self.avPlayer?.rate == 0
        {
            self.avPlayer?.play()
        } else {
            self.avPlayer?.pause()
        }
        
    }
    func setConstraint() {
        
        NSLayoutConstraint(item: playBtn, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: playerView, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: playBtn, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: playerView, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: playBtn, attribute: NSLayoutConstraint.Attribute.height, relatedBy: .equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 50).isActive = true
        
        NSLayoutConstraint(item: playBtn, attribute: NSLayoutConstraint.Attribute.width, relatedBy: .equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 50).isActive = true
        
    }
    
    @objc func playVideo(sender: UIButton!) {
        
        
        if self.avPlayer?.rate == 0 {
            self.avPlayer?.play()
            //playButton!.setImage(UIImage(named: "player_control_pause_50px.png"), forState: UIControlState.Normal)
            playBtn.setImage(UIImage.init(named: "IconPause3"), for: .normal)
            
        } else {
            self.avPlayer?.pause()
            //playButton!.setImage(UIImage(named: "player_control_play_50px.png"), forState: UIControlState.Normal)
            playBtn.setImage(UIImage.init(named: "IconPlay3"), for: .normal)
            
        }
        
        
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
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.playerView
    }
    
    @objc func movieViewTapped(_ sender: UITapGestureRecognizer) {
        
        if playBtn.isHidden == true {
            UIView.animate(withDuration: 0.2, animations: {
                self.playBtn.isHidden = false
            })
            
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.playBtn.isHidden = true
            })
        }
        
    }
}
