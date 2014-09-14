//
//  PinListViewController.swift
//  Happening_V2.1
//
//  Created by Kan Boonprakub on 8/12/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

import UIKit

class PinListViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
                            
    @IBOutlet var pinsTableView : UITableView!
    @IBOutlet var sidebarButton : UIBarButtonItem!
    
    var pins:[Pin] = []
    
    lazy var api : APIController = APIController()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        sidebarButton.target = self.revealViewController()
        sidebarButton.action = Selector("revealToggle:")

        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.api.getPins(0, longitude: 0, loadPins)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func testTapped(sender: UIBarButtonItem!) {
        self.revealViewController().revealToggle(sender)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Return number of row for pins
        return pins.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //Process result cell in the tableView
        let kCellIdentifier = "PinCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as UITableViewCell
        
        let test = self.pins[indexPath.row]
        
        cell.textLabel?.text = test.text
        cell.detailTextLabel?.text = "\(test.uploadDate)"
        
        return cell
    }

    func loadPins(results: NSDictionary) {
        //Process the jsonresult parse from API Controller
        var pinfromResult: NSArray = results["pins"] as NSArray
        //println(pinfromResult)
        var pinList: [Pin] = [];
        for pinDict in pinfromResult {
            //println(_stdlib_getTypeName(pinDict))
            if pinDict is NSDictionary {
                pinList.append(Pin(pinDict: pinDict as NSDictionary))
            }
        }
        pins = pinList
        self.pinsTableView?.reloadData()
    }
    
//    func getPageIndex() -> Int {
//        return  self.pageIndex
//    }



}

