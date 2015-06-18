//
//  WebViewConotrller.swift
//  OnTheMap
//
//  Created by Ahmed Khedr on 6/14/15.
//  Copyright (c) 2015 Ahmed Khedr. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
   
    @IBOutlet weak var urlWebView: UIWebView!
    
    var request: NSURLRequest!
    var urlString: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        urlWebView.loadRequest(self.request)
    }

    @IBAction func saveURL(sender: UIBarButtonItem) {
        
        Data.sharedInstance().mediaURL = urlString
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func ModifyURL(sender: UIBarButtonItem) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}
