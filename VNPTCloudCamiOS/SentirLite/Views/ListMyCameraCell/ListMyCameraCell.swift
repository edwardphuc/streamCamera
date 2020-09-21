//
//  ListMyCameraCell.swift
//  SentirLite
//
//  Created by Hung Nguyen on 10/16/17.
//  Copyright © 2017 Skylab. All rights reserved.
//

import UIKit

class ListMyCameraCell: UITableViewCell {

    @IBOutlet weak var statusLb: UILabel!
    @IBOutlet weak var cameraNameLb: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func fillData(camera: Camera) {
//        statusLb.text = camera.
        cameraNameLb.text = camera.cameraName
    }

}
