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
    
    var pins:Pin[] = []
    
    @lazy var api : APIController = APIController(delegate:self)
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.api.delegate = self
        
        self.api.getPins(100.0, longitude: 100.0)
        
        self.pins = api.getTest()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        
        
        //Return number of row for pins
        return pins.count;
        
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        //Process result cell in the tableView
        
        let kCellIdentifier = "HotPinCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as UITableViewCell
        
        let test = self.pins[indexPath.row]
        
        cell.text = test.title
        cell.detailTextLabel.text = "test"
        
        return cell
        
    }
    
    func didReceiveAPIResults(results: NSDictionary) {
        
        //Process the jsonresult parse from API Controller
        
    }


}

