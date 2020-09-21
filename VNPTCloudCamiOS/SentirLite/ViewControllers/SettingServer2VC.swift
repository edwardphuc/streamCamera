//
//  SettingServer2VC.swift
//  SentirLite
//
//  Created by Edward Lauv on 8/15/20.
//  Copyright © 2020 Skylab. All rights reserved.
//

import UIKit

class SettingServer2VC: UIViewController {

    @IBOutlet weak var btsave: UIButton!
    @IBOutlet weak var Domain: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        btsave.layer.cornerRadius = 5
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        // call the 'keyboardWillShow' function when the view controller receive the notification that a keyboard is going to be shown
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
            // call the 'keyboardWillHide' function when the view controlelr receive notification that keyboard is going to be hidden
          NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc override func dismissKeyboard() {
      view.endEditing(true)
    }
    @IBAction func exit(_ sender: Any) {
        self.dismiss(animated: true)
    }
    @IBAction func saveDomain(_ sender: Any) {
        URLs.server2 = Domain.text!
        self.dismiss(animated: true)
    }
    

    @objc func keyboardWillShow(notification: NSNotification) {
            
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
           // if keyboard size is not available for some reason, dont do anything
           return
        }
      
      // move the root view up by the distance of keyboard height
      self.view.frame.origin.y = 0 - keyboardSize.height
    }

    @objc func keyboardWillHide(notification: NSNotification) {
      // move back the root view origin to zero
      self.view.frame.origin.y = 0
    }

}
