//
//  SigninPageContentViewcontroller.swift
//  Happining_V2.1
//
//  Created by Tanthawat Khemavast on 5/10/14.
//  Copyright (c) 2014 Kan Boonprakub. All rights reserved.
//

import Foundation

class SigninPageContentViewController: UIViewController {
    @IBOutlet var text: UITextField!
    @IBOutlet var nextButton: UIButton!
    
    var inputType: String = ""
    var pageIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.text.placeholder? = self.inputType
        if(self.inputType == "Password") {
            
        }
        if(self.inputType == "Username") {
            self.nextButton.setTitle("Done", forState: UIControlState.Normal)
            println("\(inputType) \(pageIndex)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}