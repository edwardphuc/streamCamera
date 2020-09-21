//
//  PopUpCell.swift
//  DonePaperApp
//
//  Created by TuanNguyen on 4/18/17.
//  Copyright © 2017 Done Paper. All rights reserved.
//
    
import UIKit

class PopUpCell: UITableViewCell {

    @IBOutlet weak var nameItemLbl: UILabel!
    @IBOutlet weak var iconTickImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func filldata(data:FilterItem){
        self.nameItemLbl.text = data.name
        iconTickImg.isHidden = !data.isSelected
    }
}
