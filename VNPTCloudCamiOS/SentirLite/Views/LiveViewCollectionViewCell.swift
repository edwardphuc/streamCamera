//
//  LiveViewCollectionViewCell.swift
//  SentirLite
//
//  Created by Hung Nguyen on 7/25/17.
//  Copyright © 2017 Skylab. All rights reserved.
//

import UIKit

class LiveViewCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var cameraNameLb: UILabel!
    
    @IBOutlet weak var iconPlayImg: UIImageView!
    @IBOutlet weak var statusCamera: UILabel!
    @IBOutlet weak var cameraImage: UIImageView!
    
    @IBOutlet weak var playerView: UIView!
    func fillData(data: Camera) {
        self.cameraNameLb.text = data.cameraName
        self.backgroundColor = UIColor.lightGray
    }
    override func awakeFromNib() {
        if UIDevice().screenType == .iPhone5 {
            self.statusCamera.font = UIFont(name: "SF UI Text", size: 12)
            self.cameraNameLb.font = UIFont(name: "SF UI Text", size: 13)
        }
        
    }
    
}
