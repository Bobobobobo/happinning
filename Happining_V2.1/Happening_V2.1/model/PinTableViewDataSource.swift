//
//  PinTableViewDatasource.swift
//  Happining_V2.1
//
//  Created by Sopana Thitipariwat on 11/26/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

import UIKit

protocol PinListDelegate : NSObjectProtocol {
    func pinListShouldHideComposerView()
    func pinListShouldUpdateComposerView(constant:CGFloat)
    func pinListShouldLoadMore()
}

class PinTableViewDataSource:NSObject, UITableViewDataSource, UITableViewDelegate {
    
    let kCellIdentifier = "PinCell"

    var pins:[Pin] = []

    var hasMore = false
    var isDragging = false
    var shouldHidePost = false
    var beginPoint = CGPointZero
    
    var delegate:PinListDelegate?

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Return number of row for pins
        return self.pins.count;
    }
    
    func configureCellFor(tableView:UITableView, atIndexPaht indexPath: NSIndexPath) -> UITableViewCell {
        //Process result cell in the tableView
        var cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as PinTableViewCell
        
        var pin = self.pins[indexPath.row]
        
        cell.pinTitle?.text = pin.text
        
        if pin.pinName != nil {
            cell.pintypeImage?.image = UIImage(named: "\(pin.pinName!).png")
        }
        
        var locality = ""
        if strlen(pin.location.subLocality) > 0 {
            locality = pin.location.subLocality
        }
        
        cell.locaionLabel?.text = locality
        cell.timeLabel?.text = pin.uploadDate.formattedAsTimeAgo()
        
        if pin.distance >= 0.1 {
            cell.distanceLabel?.text = NSString(format: "%.2f km", pin.distance)
        } else {
            cell.distanceLabel?.text = NSString(format: "%.2f m", pin.distance*1000)
        }
        
        var baseURL = BASE_URL
        if pin.imageURL == nil || strlen(pin.imageURL!) == 0 {
            cell.imageHeight!.constant = 0.0
            cell.pinImage?.hidden = true
        } else {
            cell.imageHeight!.constant = 200.0
            cell.pinImage?.hidden = false
            
            var urlString = "\(baseURL)\(pin.imageURL!)"
            cell.pinImage?.sd_setImageWithURL(NSURL(string: urlString))
        }
        
        cell.profileImage?.sd_setImageWithURL(NSURL(string: pin.userImageURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!))
        cell.userName?.text = pin.userName
        
        // Make sure the constraints have been added to this cell, since it may have just been created from scratch
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
        return cell
    }
    
    func calculateHeightForConfiguredSizingCell(cell:UITableViewCell) -> CGFloat {
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        var size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        return size.height
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.configureCellFor(tableView, atIndexPaht: indexPath)
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 360
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var cell = self.configureCellFor(tableView, atIndexPaht: indexPath)
        return self.calculateHeightForConfiguredSizingCell(cell)
        //return UITableViewAutomaticDimension
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        isDragging = true
        beginPoint = scrollView.contentOffset
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isDragging = false
        endingScroll()
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        isDragging = false
        endingScroll()
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        isDragging = false
        endingScroll()
    }
    
    func endingScroll() {
        if self.delegate != nil && self.delegate!.respondsToSelector(Selector("pinListShouldHideComposerView")) {
            self.delegate!.pinListShouldHideComposerView()
        }
    }
    
    func scrollViewDidScroll(aScrollView: UIScrollView) {
        var offset:CGPoint = aScrollView.contentOffset
        var bounds:CGRect = aScrollView.bounds
        var size:CGSize = aScrollView.contentSize
        var inset:UIEdgeInsets = aScrollView.contentInset
        var y:CGFloat = offset.y + bounds.size.height - inset.bottom
        var h:CGFloat = size.height
        var reload_distance:CGFloat = 10
        
        if((y > (h + reload_distance)) && hasMore) {
            if self.delegate != nil && self.delegate!.respondsToSelector(Selector("pinListShouldLoadMore")) {
                self.delegate!.pinListShouldLoadMore()
            }
        } else if beginPoint.y < offset.y {
            if self.delegate != nil && self.delegate!.respondsToSelector(Selector("pinListShouldUpdateComposerView:")) {
                self.delegate!.pinListShouldUpdateComposerView((offset.y - beginPoint.y))
            }
        }
    }
}
