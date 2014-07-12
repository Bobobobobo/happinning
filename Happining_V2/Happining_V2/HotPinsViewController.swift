//
//  HotPinsViewController.swift
//  Happining_V2
//
//  Created by Kan Boonprakub on 7/8/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

import UIKit

class HotPinsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, APIControllerProtocol {
    
    @IBOutlet var pinsTableView : UITableView
    
    @lazy var api : APIController = APIController(delegate:self)
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        self.api.delegate = self
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        
        
        //Return number of row for pins
        return 0;
        
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        //Process result cell in the tableView
        return nil
        
    }
    
    func didReceiveAPIResults(results: NSDictionary) {
        
        //Process the jsonresult parse from API Controller
        
    }


}

