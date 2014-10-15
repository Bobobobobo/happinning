//
//  EmailViewController.swift
//  Happining_V2.1
//
//  Created by Tanthawat Khemavast on 9/10/14.
//  Copyright (c) 2014 Kan Boonprakub. All rights reserved.
//

import Foundation
import QuartzCore

class EmailViewController: UIViewController {
    
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var emailTextField: UITextField!
    
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
        var destController: UIViewController = segue.destinationViewController as UIViewController
        
        if let passViewController: PasswordViewController = destController as? PasswordViewController {
            passViewController.email = emailTextField.text
        }
    }
    
}