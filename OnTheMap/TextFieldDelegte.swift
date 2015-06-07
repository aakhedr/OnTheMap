//
//  TextFieldDelegte.swift
//  OnTheMap
//
//  Created by Ahmed Khedr on 6/7/15.
//  Copyright (c) 2015 Ahmed Khedr. All rights reserved.
//

import UIKit

class TextFieldDelegte: NSObject, UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }

    
}
