//
//  UsernameViewController.swift
//  Happining_V2.1
//
//  Created by Tanthawat Khemavast on 11/10/14.
//  Copyright (c) 2014 Kan Boonprakub. All rights reserved.
//

import Foundation

class UsernameViewController: UIViewController {
    
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var usernameTextField: UITextField!
    
    var email: String?
    var password: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //self.nextButton.layer.cornerRadius = self.nextButton.bounds.size.width/5.0
        //self.nextButton.layer.borderWidth = 1.0
        //self.nextButton.layer.borderColor = self.nextButton.titleLabel?.textColor.CGColor
        //self.nextButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size:25)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneTouchUpInside(sender: AnyObject) {
        var username: String = usernameTextField.text
        println("email:\(email!), password:\(password!), username:\(username)")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}