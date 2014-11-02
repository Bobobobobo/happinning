//
//  LoginCollectionViewCell.swift
//  Happining_V2.1
//
//  Created by Sopana Thitipariwat on 11/2/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

import UIKit

protocol LoginCollectionViewCellDelegate : NSObjectProtocol {
    func loginCellDidResignTextField(cell: LoginCollectionViewCell)
}

class LoginCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    var delegate: LoginCollectionViewCellDelegate?
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if self.delegate != nil {
            var delegate = self.delegate!
            if delegate.respondsToSelector(Selector("loginCellDidResignTextField:")) {
                delegate.loginCellDidResignTextField(self)
            }
        }
    }
}
