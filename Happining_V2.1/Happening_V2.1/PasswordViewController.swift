//
//  PasswordViewController.swift
//  Happining_V2.1
//
//  Created by Tanthawat Khemavast on 11/10/14.
//  Copyright (c) 2014 Kan Boonprakub. All rights reserved.
//

import Foundation

class PasswordViewController: UIViewController {
    
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var passwordTextField: UITextField!
    
    var email: String?
    
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destViewController: UIViewController = segue.destinationViewController as UIViewController
        
        if let userViewController: UsernameViewController = destViewController as? UsernameViewController {
            userViewController.email = self.email!
            userViewController.password = passwordTextField.text
        }
    }
}