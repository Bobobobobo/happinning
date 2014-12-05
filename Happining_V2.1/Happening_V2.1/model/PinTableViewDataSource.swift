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
    func pinListShouldLoadMore()
    func pinListDidEndScrolling()
}

class PinTableViewDataSource:NSObject, UITableViewDataSource, UITableViewDelegate, PinTableViewCellDelegate {
    
    let kCellIdentifier = "PinCell"

    var pins:[Pin] = []

    var hasMore = false
    var isScrolling = false
    var shouldHidePost = false
    var beginPoint = CGPointZero
    var tableView:UITableView?
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
        cell.delegate = self
        
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

        if cell.mediaPlayer.playbackState == .Playing {
            cell.mediaPlayer.stop()
        }
        
        cell.mediaPlayer.view.hidden = true

        if pin.distance >= 0.1 {
            cell.distanceLabel?.text = NSString(format: "%.1f km", pin.distance)
        } else {
            cell.distanceLabel?.text = NSString(format: "%.1f m", pin.distance*1000)
        }
        
        var baseURL = BASE_URL
        if pin.thumbURL == nil || strlen(pin.thumbURL!) == 0 {
            cell.imageHeight!.constant = 0.0
            cell.pinImage?.hidden = true
        } else {
            cell.imageHeight!.constant = 200.0
            cell.pinImage?.hidden = false
            
            var urlString = "\(baseURL)\(pin.thumbURL!)"

            if pin.imageURL != nil && strlen(pin.imageURL!) > 0 {
                urlString = "\(baseURL)\(pin.imageURL!)"
                cell.pinImage?.contentMode = .ScaleAspectFill
            } else if pin.videoURL != nil && strlen(pin.videoURL!) > 0 {
                cell.mediaPlayer.contentURL = NSURL(string: "\(baseURL)\(pin.videoURL!)")
                cell.mediaPlayer.view.hidden = false
                cell.mediaPlayer.view.alpha = 0.0
                cell.mediaPlayer.prepareToPlay()
                cell.pinImage?.contentMode = .ScaleAspectFit
            }
            
            cell.pinImage?.sd_setImageWithURL(NSURL(string: urlString))
        }
        
        cell.profileImage?.sd_setImageWithURL(NSURL(string: pin.userImageURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!))
        cell.userName?.text = pin.userName
        
        updateLikeAtCell(cell, withPin: pin)
        
        if pin.commentsNum > 0 {
            cell.commentLabel.text = NSString(format: "%d Comment%@", pin.commentsNum, (pin.commentsNum > 1 ? "s" : ""))
        } else {
            cell.commentLabel.text = "Comment"
        }
        
        // Make sure the constraints have been added to this cell, since it may have just been created from scratch
        //cell.setNeedsUpdateConstraints()
        //cell.updateConstraintsIfNeeded()
        
        return cell
    }
    
    func calculateHeightForConfiguredSizingCell(cell:UITableViewCell) -> CGFloat {
//        cell.setNeedsLayout()
//        cell.layoutIfNeeded()
//        var size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
//        return size.height
        
        var pinCell = cell as PinTableViewCell
        var attrText = NSAttributedString(string: pinCell.pinTitle.text!, attributes: [NSFontAttributeName : pinCell.pinTitle.font])
        
        var rect:CGRect = attrText.boundingRectWithSize(CGSizeMake(CGRectGetWidth(pinCell.pinTitle.frame), CGFloat.max), options: .UsesLineFragmentOrigin, context: nil)

        return 143 + CGRectGetHeight(rect) + pinCell.imageHeight!.constant
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.configureCellFor(tableView, atIndexPaht: indexPath)
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 360
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var pin = self.pins[indexPath.row]
        
        if pin.height > 0 {
            return pin.height
        }
        
        var cell = self.configureCellFor(tableView, atIndexPaht: indexPath)
        pin.height = self.calculateHeightForConfiguredSizingCell(cell)
        return pin.height
        //return UITableViewAutomaticDimension
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        isScrolling = true
        beginPoint = scrollView.contentOffset
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            isScrolling = false
            endingScroll(scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        isScrolling = false
        endingScroll(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        isScrolling = false
        endingScroll(scrollView)
    }
    
    func endingScroll(scrollView: UIScrollView) {
        if self.delegate != nil {
            if self.delegate!.respondsToSelector(Selector("pinListShouldHideComposerView")) {
                self.delegate!.pinListShouldHideComposerView()
            }
            
            if self.delegate!.respondsToSelector(Selector("pinListDidEndScrolling")) {
                self.delegate!.pinListDidEndScrolling()
            }
        }
        
        //playVideo(scrollView)
    }
    
    func playVideo(scrollView: UIScrollView) {
        var tableView = scrollView as UITableView
        for cell in tableView.visibleCells() {
            var pinCell = cell as PinTableViewCell
            var window:UIView = (UIApplication.sharedApplication().delegate?.window!)!
            var cellRect = window.convertRect(cell.bounds, fromView: cell as? UIView)
            var indexPath:NSIndexPath? = tableView.indexPathForCell(pinCell)
            
            if CGRectContainsRect(window.bounds, cellRect){
                var pin = self.pins[indexPath!.row]
                
                if pin.videoURL != nil && strlen(pin.videoURL!) > 0 {
                    pinCell.mediaPlayer.play()
                    return
                }
            }
        }
    }
    
    func scrollViewDidScroll(aScrollView: UIScrollView) {
        var offset:CGPoint = aScrollView.contentOffset
        var bounds:CGRect = aScrollView.bounds
        var size:CGSize = aScrollView.contentSize
        var inset:UIEdgeInsets = aScrollView.contentInset
        var y:CGFloat = offset.y + bounds.size.height - inset.bottom
        var h:CGFloat = size.height
        var reload_distance:CGFloat = -100
        
        if((y > (h + reload_distance)) && hasMore) {
            if self.delegate != nil && self.delegate!.respondsToSelector(Selector("pinListShouldLoadMore")) {
                self.delegate!.pinListShouldLoadMore()
            }
        } else if beginPoint.y < offset.y {
            
        }
    }
    
    func updateLikeAtCell(cell:PinTableViewCell!, withPin pin:Pin) {
        if pin.likesNum > 0 {
            cell.likeLabel.text = NSString(format: "%d Like%@", pin.likesNum, (pin.likesNum > 1 ? "s" : ""))
        } else {
            cell.likeLabel.text = "Like"
        }
        
        cell.likeButton?.selected = pin.isLike
    }

    func pinCellLikeAtCell(cell:PinTableViewCell!) {
        var indexPath:NSIndexPath! = self.tableView?.indexPathForCell(cell)!
        var pin = self.pins[indexPath.row]
        
        pin.isLike = !pin.isLike
        pin.likesNum += (pin.isLike ? 1 : -1)

        updateLikeAtCell(cell, withPin: pin)
        
        var request = PinLikeRequest()
        request.pinID = pin.pinId
        request.isLike = pin.isLike
        request.userID = User.currentUser.userID!
        request.request { (result) -> Void in
            if result.error == nil {
                pin.isLike = !pin.isLike
                pin.likesNum += (pin.isLike ? 1 : -1)
                
                self.updateLikeAtCell(cell, withPin: pin)
            }
        }
    }
    
    func pinCellCommentAtCell(cell:PinTableViewCell!) {
        var indexPath:NSIndexPath! = self.tableView?.indexPathForCell(cell)!
        var pin = self.pins[indexPath.row]
    }
}
