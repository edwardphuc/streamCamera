//
//  StorageFullScreenVC.swift
//  SentirLite
//
//  Created by Hung Nguyen on 9/29/18.
//  Copyright © 2018 Skylab. All rights reserved.
//

import UIKit
import Photos

class StorageFullScreenVC: BaseVC, VGPlayerDelegate, VGPlayerViewDelegate, UIScrollViewDelegate {
    static let identifier = "StorageFullScreenVC"
    
    class func newVC() ->  StorageFullScreenVC {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let vc = storyBoard.instantiateViewController(withIdentifier: identifier) as! StorageFullScreenVC
        
        return vc
    }

    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    let closeBtn = UIButton(frame: CGRect(x: 15, y: 50, width: 70, height: 45))
    var player: VGPlayer = VGPlayer()
    var record: Record?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let recordSelected = record else {return}
        let url = recordSelected.viewRecordUrl
//        self.player = VGPlayer(URL: URL(string: url)!)
        self.player.delegate = self
        scrollView.delegate = self
        playerView.addSubview((player.displayView))
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 5.0
        self.player.displayView.titleLabel.isHidden = true
        self.player.displayView.loadingIndicator.stopAnimating()
        self.player.displayView.closeButton.isHidden = true
        self.player.delegate = self
        self.player.displayView.delegate = self
        self.player.displayView.snp.makeConstraints { [weak self] (make) in
            guard let strongSelf = self else { return }
            make.top.equalTo(strongSelf.playerView.snp.top)
            make.left.equalTo(strongSelf.playerView.snp.left)
            make.right.equalTo(strongSelf.playerView.snp.right)
            make.bottom.equalTo(strongSelf.playerView.snp.bottom)
        }
        self.player.backgroundMode = .suspend
        
        addCloseBtn()
        self.player.replaceVideo(URL(string: url)!)
        self.player.play()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let recordSelected = record else {return}
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            if self.record?.seekToTime != nil && self.player.playerItem?.status == .readyToPlay {
                let cmTime = CMTimeMake(value: Int64(recordSelected.seekToTime!), timescale: 1)
                self.player.playerItem?.seek(to: cmTime, completionHandler: { (finished) in
                })
            }
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return self.playerView
        
    }
    func addCloseBtn() {
        closeBtn.setTitle("Done", for: .normal)
        
        closeBtn.setTitleColor(UIColor.white, for: .highlighted)
        
        closeBtn.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        
        self.view.addSubview(closeBtn)
    }
    @objc func closeView() {
        self.dismiss(animated: true, completion: nil)
    }

}
