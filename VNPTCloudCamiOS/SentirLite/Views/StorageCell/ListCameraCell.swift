//
//  ListCameraCell.swift
//  SentirLite
//
//  Created by TuanNguyen on 7/26/17.
//  Copyright © 2017 Skylab. All rights reserved.
//

import UIKit

class ListCameraCell: UITableViewCell {
    @IBOutlet weak var saveDateLbl: UILabel!
    @IBOutlet weak var startDateLbl: UILabel!
    @IBOutlet weak var finishDateLbl: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func fillData(data:Record,time:DatePickerType) {
        let timeStr = time.date.timeIntervalSince1970.format2String(format: "MMM dd, YYYY")
        self.saveDateLbl.text = timeStr
        
        if let startTimeInt = Int(data.startTime) {
            let timeStr = TimeInterval(exactly: startTimeInt)?.format2String(format: "HH:mm:ss")
            self.startDateLbl.text = timeStr
        }
        
        if let finishTimeInt = Int(data.endTime) {
            let timeStr = TimeInterval(exactly: finishTimeInt)?.format2String(format: "HH:mm:ss")
            self.finishDateLbl.text = timeStr
        }
    }

}
