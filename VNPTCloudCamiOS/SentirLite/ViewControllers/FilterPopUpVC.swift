//
//  PopUpVC.swift
//  DonePaperApp
//
//  Created by TuanNguyen on 4/18/17.
//  Copyright © 2017 Done Paper. All rights reserved.
//

import UIKit

protocol PopUpVCDelegate:class {
    func chooseFilter(FilterPopUpVC:FilterPopUpVC, items:[FilterItem])
}

struct FilterItem {
    var name:String
    var isSelected:Bool = false
    var cameraCode: String
}
class FilterPopUpVC: UIViewController {
    
    weak var delegate : PopUpVCDelegate?
    static let identifier = "PopUpVC"

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titlePopupLbl: UILabel!
    var filterList : [FilterItem] = []
    var tittlePopup:String?
    var allowMultiSelection = true
    
    
    class func newVC() ->  FilterPopUpVC{
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyBoard.instantiateViewController(withIdentifier: identifier) as! FilterPopUpVC
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        titlePopupLbl.text = tittlePopup
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
extension FilterPopUpVC: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PopUpCell", for: indexPath) as! PopUpCell
        
        let item = filterList[indexPath.row]
        
        cell.filldata(data: item)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var filterItem = filterList[indexPath.row]
        
        if allowMultiSelection {
            
            filterItem.isSelected = !filterItem.isSelected
            filterList[indexPath.row] = filterItem // re-assign ***
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
        } else {
            
            for i in 0..<filterList.count {
                filterList[i].isSelected = false
            }
            
            filterList[indexPath.row].isSelected = true
            tableView.reloadData()
        }
        
        self.delegate?.chooseFilter(FilterPopUpVC: self, items: filterList)
    
    }
}
