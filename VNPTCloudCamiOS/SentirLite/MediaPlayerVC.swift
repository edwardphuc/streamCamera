//
//  ViewController.swift
//  SentirLite
//
//  Created by Hung Nguyen 24/7/2017.
//  Copyright © 2017 Hung Nguyen. All rights reserved.
//

import UIKit

func getDocumentsURL() -> URL {
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    return documentsURL
}

func fileInDocumentsDirectory(filename: String) -> String {
    
    let fileURL = getDocumentsURL().appendingPathComponent(filename)
    return fileURL.path
    
}

class MediaPlayerVC: BaseVC, VLCMediaPlayerDelegate,UIScrollViewDelegate {
    
    static let identifier = "MediaPlayerVC"
    
    class func newVC() ->  MediaPlayerVC {
    
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let vc = storyBoard.instantiateViewController(withIdentifier: identifier) as! MediaPlayerVC
        
        return vc
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var movieView: UIView!
    
    var mediaPlayer = VLCMediaPlayer()
    
    var URLString: String = ""
    
    let playBtn = UIButton(frame: CGRect(x: 100, y: 100, width: 50, height: 50))
    
    let closeBtn = UIButton(frame: CGRect(x: 15, y: 50, width: 70, height: 45))
    
    var cameraCode: String = ""
    
    var CameraDS: CameraDataSource = CameraDataSource()
    
    let ad = UIApplication.shared.delegate as! AppDelegate
    
    let orientation = UIDevice.current.orientation
//    var options: [Any] = ["--extraintf="]
    var options: [Any] = ["--rtsp-tcp", "--no-drop-late-frames", "--no-skip-frames","--extraintf=", "--gain=0"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.showLoading()
        restrictRotation(false)
        
        mediaPlayer = VLCMediaPlayer(options: options)
        scrollView.delegate = self

        //Add rotation observer
        NotificationCenter.default.addObserver(self, selector: #selector(MediaPlayerVC.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        //Add tap gesture to movieView for play/pause
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(MediaPlayerVC.movieViewTapped(_:)))
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTap.numberOfTapsRequired = 2
        
        view.addGestureRecognizer(doubleTap)
        
        self.movieView.addGestureRecognizer(gesture)

        //Add movieView to view controller
        
        self.scrollView.addSubview(self.movieView)
        
        self.scrollView.minimumZoomScale = 1.0
        
        self.scrollView.maximumZoomScale = 5.0
                
        playBtn.setImage(UIImage.init(named: "IconPause3"), for: .normal)
        
        playBtn.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
        
        playBtn.translatesAutoresizingMaskIntoConstraints = false
        
        playBtn.isHidden = true
        
        closeBtn.setTitle("Done", for: .normal)
        
        closeBtn.setTitleColor(UIColor.white, for: .highlighted)
        
        closeBtn.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        
        self.view.addSubview(closeBtn)
        
        self.view.addSubview(playBtn)
        
        setConstraint()
        
        mediaPlayer.delegate = self
        
    }

    
    override func viewDidAppear(_ animated: Bool) {
        
        //Playing RTSP from internet
        
        self.movieView.contentMode = .scaleAspectFill
        
        guard let url = URL(string: self.URLString) else {return}
        
        let media = VLCMedia(url: url)
        
        self.mediaPlayer.media = media
        self.mediaPlayer.media.addOptions(["network-caching": 3000])

        self.mediaPlayer.delegate = self
        
        self.mediaPlayer.drawable = self.movieView
        
        self.mediaPlayer.play()
        
        self.hideLoading(delay: 6)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.mediaPlayer.state.rawValue == 4 {
                
                self.hideLoading(delay: 0)
                self.dismiss(animated: true, completion: nil)
            }
        }


    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func restrictRotation(_ restriction: Bool) {
        let appDelegate: AppDelegate? = (UIApplication.shared.delegate as? AppDelegate)
        appDelegate?.restrictRotation = restriction
    }

    @objc func doubleTapped() {
        
        self.scrollView.zoomScale = 1.0
    }
    
    @objc func closeView(sender: UIButton) {
       
        
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        let myImage = "\(cameraCode).png"
        let imagePath = fileInDocumentsDirectory(filename: myImage)
        mediaPlayer.saveVideoSnapshot(at: "\(imagePath)", withWidth: 300, andHeight: 200)
        mediaPlayer.stop()
        self.hideLoading(delay: 0)
        self.dismiss(animated: true, completion: nil)
    }
    
    func setConstraint() {
        
        NSLayoutConstraint(item: playBtn, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: playBtn, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: playBtn, attribute: NSLayoutConstraint.Attribute.height, relatedBy: .equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 55).isActive = true
        
        NSLayoutConstraint(item: playBtn, attribute: NSLayoutConstraint.Attribute.width, relatedBy: .equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 55).isActive = true

    }
    
    @objc func playVideo(sender: UIButton!) {

        if mediaPlayer.isPlaying {
            
            mediaPlayer.pause()
            
            let remaining = mediaPlayer.remainingTime
            
            let time = mediaPlayer.time
            
            playBtn.setImage(UIImage.init(named: "IconPlay3"), for: .normal)
            
            print("Paused at \(time) with \(remaining) time remaining")
        } else {
            
            mediaPlayer.play()
            
            print("Playing")
            
            playBtn.setImage(UIImage.init(named: "IconPause3"), for: .normal)
            
        }
        
    }
    func getDocumentsDirectory() -> URL {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        let documentsDirectory = paths[0]
        
        return documentsDirectory
    }
    
    
    func createFolder(folderName:String) throws {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        let documentsDirectory = paths[0]
        
        let folderURL = documentsDirectory.appendingPathComponent(folderName)
        
        if !FileManager.default.fileExists(atPath: folderURL.absoluteString) {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true,   attributes: nil)
        }
    }
    
    func getLinkVideo() {
        let sessionKey = ad.logginUser?.sessionKey

        let headers: [String: String] = [
        
            "X-Tokens": sessionKey ?? ""
        ]
        CameraDS.getLinkVideo(cameraCode: self.cameraCode, headers: headers, completion: { (linkVideo) in
            
            self.URLString = linkVideo
            
        
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
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return self.movieView
    
    }
    
    @objc func rotated() {
        self.scrollView.zoomScale = 0.0

        if (orientation.isLandscape) {
            print("Switched to landscape")

        } else if(orientation.isPortrait) {
            print("Switched to portrait")
        }
        
        self.movieView.frame = self.view.frame

    }

    @objc func movieViewTapped(_ sender: UITapGestureRecognizer) {
        if sender.numberOfTapsRequired == 2 {
            print("detect")
        }
        
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
