//
//  ChangePasswordVC.swift
//  SentirLite
//
//  Created by Hung Nguyen on 10/16/17.
//  Copyright © 2017 Skylab. All rights reserved.
//

import UIKit
import WebKit

class ChangePasswordVC: UIViewController,WKUIDelegate, WKScriptMessageHandler {

    
    var webView: WKWebView!
    
    private var userContentController: WKUserContentController!
    
    override func loadView() {
        userContentController = WKUserContentController()
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = userContentController
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPage(urlString: URLs.changePassword)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        
       
    }
    
    func loadPage(urlString: String) {
        userContentController.removeAllUserScripts()
        
        let userScript = WKUserScript(source: scriptWithDOMSelector(),
                                      injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
                                      forMainFrameOnly: true)
        
        userContentController.addUserScript(userScript)
        
        let url = URL(string: urlString)!
        webView.load(URLRequest(url: url))
        
    }
    
    func scriptWithDOMSelector() -> String {
        return  ""
    }
}
