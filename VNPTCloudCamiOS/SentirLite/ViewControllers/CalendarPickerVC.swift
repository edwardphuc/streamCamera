//
//  CalendarPickerVC.swift
//  DonePaperApp
//
//  Created by TuanNguyen on 4/20/17.
//  Copyright © 2017 Done Paper. All rights reserved.
//

import UIKit
import FSCalendar

protocol CalendarPickerVCDelegate:class {
    func UserChooseDate(CalendarPickerVC:CalendarPickerVC,date:DatePickerType,filterTypeStrr:String)
}

struct DatePickerType {
    var dateString:String
    var date:Date
}

class CalendarPickerVC: UIViewController,FSCalendarDelegate,FSCalendarDataSource {
    weak var delegate : CalendarPickerVCDelegate?
    var datetype:DatePickerType?
    var filterType:String?
    
    @IBOutlet weak var calendar: FSCalendar!
    fileprivate let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter
    }()
    
    static let identifier = "CalendarPickerVC"
    class func newVC() ->  CalendarPickerVC{
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyBoard.instantiateViewController(withIdentifier: identifier) as! CalendarPickerVC
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        calendar.select(datetype?.date)
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("change page to \(self.formatter.string(from: calendar.currentPage))")
        
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let dateString:String = self.formatter.string(from: date)
        datetype = DatePickerType(dateString: dateString, date: date)

        self.delegate?.UserChooseDate(CalendarPickerVC: self, date: datetype!, filterTypeStrr: filterType!)
        
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
