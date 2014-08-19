//
//  PinListViewController.swift
//  Happening_V2.1
//
//  Created by Kan Boonprakub on 8/12/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

import UIKit

class PinListViewController: UIViewController , UITableViewDelegate, UITableViewDataSource,  APIControllerProtocol {
                            
    @IBOutlet var pinsTableView : UITableView?
    @IBOutlet var sidebarButton : UIBarButtonItem!
    
    var pins:[Pin] = []
    
    lazy var api : APIController = APIController(delegate:self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        sidebarButton.target = self.revealViewController()
        sidebarButton.action = Selector("revealToggle:")

        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        self.api.delegate = self
        //self.navi.delegate = self
        
        self.pins = api.getTest()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func testTapped(sender: UIBarButtonItem!) {
        self.revealViewController().revealToggle(sender)
    }


    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        
        
        //Return number of row for pins
        return pins.count;
        
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        //Process result cell in the tableView
        
        let kCellIdentifier = "PinCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as UITableViewCell
        
        let test = self.pins[indexPath.row]
        
        cell.textLabel.text = test.title
        cell.detailTextLabel.text = "test"
        
        return cell
        
    }
    
    func didReceiveAPIResults(results: NSDictionary) {
        
        //Process the jsonresult parse from API Controller
        
    }
    
//    func getPageIndex() -> Int {
//        return  self.pageIndex
//    }



}

