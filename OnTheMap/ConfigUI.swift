//
//  ConfigUI.swift
//  OnTheMap
//
//  Created by Ahmed Khedr on 6/6/15.
//  Copyright (c) 2015 Ahmed Khedr. All rights reserved.
//

import UIKit

class ConfigUI: NSObject {
    
    /* Add Buttons and actions to the Table and Map View Controllers */
    func configureNavBarButtons(viewController: UIViewController) {
        
        let logoutButton = UIBarButtonItem(
            title: "Logout",
            style: UIBarButtonItemStyle.Plain,
            target: self,
            action: "logout")
        
        let refreshButton = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.Refresh,
            target: self,
            action: "refresh")
        
        let pinButton = UIBarButtonItem(
            image: UIImage(named: "pin"),
            style: UIBarButtonItemStyle.Plain,
            target: self,
            action: "pin")
        
        viewController.parentViewController!.navigationItem.leftBarButtonItem = logoutButton
        viewController.parentViewController!.navigationItem.rightBarButtonItems = [
            refreshButton,
            pinButton
        ]
    }
    
    /* Actions */
    
    func logout() {
        
        println("logout")
    }
    
    func refresh() {
        
        println("refresh")
    }
    
    func pin() {
        
        println("pin")
    }
    
    /* Shared Instance */
    class func sharedInstance() -> ConfigUI {
        
        struct Singleton {
            static var sharedInstance = ConfigUI()
        }
        return Singleton.sharedInstance
    }
    

}
