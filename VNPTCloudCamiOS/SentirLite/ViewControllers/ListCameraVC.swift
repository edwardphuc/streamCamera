//
//  ListCameraVC.swift
//  SentirLite
//
//  Created by Hung Nguyen on 10/16/17.
//  Copyright © 2017 Skylab. All rights reserved.
//

import UIKit

class ListCameraVC: BaseVC {

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func addCamera(_ sender: Any) {

    }
    
    let ad = UIApplication.shared.delegate as! AppDelegate
    var cameraDS: CameraDataSource = CameraDataSource()

    var listCamera : [Camera] = []
    var arrayCameraCode: [String] = []
    var statusDict: [String: String] = [:]

    var token: String = "f0e17ff68f2089a1dff5b7c8280b8c92"
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
        NotificationCenter.default.addObserver(forName: kUserDidChangeIndexTabPage, object: nil, queue: nil) { [weak self] notif in
            guard let `self` = self else {return}
            self.hideLoading(delay: 0)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getListCamera()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getListCamera() {
        let sessionKey = ad.logginUser?.sessionKey
        
        let headers: [String: String] = [
            
            "X-Tokens": sessionKey ?? token
        ]
        cameraDS.getListCamera(headers: headers, completion: { (camList) in
            
            self.listCamera = camList
            self.tableView.reloadData()
            self.checkStatusCamera()
            
        }) { (error) in
            if error.msg.range(of: "Cannot connect server, please change URL !") != nil {
                
                self.errorPopup(title: error.code , subTitle: error.msg, completion: nil)
                
            }else if error.msg == "Session expired." || error.msg == "Incorrect session." {
                NotificationCenter.default.post(name: kUserReLogin, object: nil)
                
            } else {
                self.errorPopup(title: error.code , subTitle: error.msg, completion: nil)
                
            }
        }
    }
    func checkStatusCamera() {
        let sessionKey = ad.logginUser?.sessionKey
        let headers: [String: String] = [
            
            "X-Tokens": sessionKey ?? ""
        ]
        
        for item in self.listCamera {
            
            self.arrayCameraCode.append(item.cameraCode)
        }
        
        cameraDS.checkStatusCamera(parameters: arrayCameraCode, headers: headers,sessionKey: sessionKey ?? "", completion: { (result) in
            
            self.statusDict = result
            
            self.tableView.reloadData()
            
        }) { (error) in
            print(error)
        }
    }
}

extension ListCameraVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listCamera.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListMyCameraCell", for: indexPath) as! ListMyCameraCell
        
        
        if let camera: Camera =  listCamera[indexPath.row] {
            cell.fillData(camera: camera)
            if  statusDict[camera.cameraCode] == "READY" {
                cell.statusLb.text = "Online"
            } else {
                cell.statusLb.text = "Offline"
            }
        }
        
        return cell
    }
}
