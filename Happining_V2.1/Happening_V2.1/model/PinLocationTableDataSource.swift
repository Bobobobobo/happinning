//
//  PinLocationTableDataSource.swift
//  Happining_V2.1
//
//  Created by Sopana Thitipariwat on 12/4/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

import UIKit

class PinLocationTableDataSource:NSObject, UITableViewDataSource, UITableViewDelegate {
    var locations:[Location] = []
    var tableData:[Location] = []
    var kCellIdentifier = "cell"
    
    func searchWith(keyword:String) {
        var locsFiltered = self.locations.filter( { (location: Location) -> Bool in
            return location.subLocality.lowercaseString.rangeOfString(keyword.lowercaseString) != nil
        })
        
        self.tableData = locsFiltered as [Location]
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Return number of row for pins
        
        if self.tableData.count == 0 {
            self.tableData = self.locations
        }
        
        return self.tableData.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as UITableViewCell
        var location = self.tableData[indexPath.row]
        cell.textLabel.text = location.subLocality
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var location = self.tableData[indexPath.row] as Location
        println("Select \(location.subLocality)")
        UserLocation.manager.delegate!.userDidSelectLocation(location)
    }
}
