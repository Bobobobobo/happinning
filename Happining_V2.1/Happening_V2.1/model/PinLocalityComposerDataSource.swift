//
//  PinLocalityComposerDataSource.swift
//  Happining_V2.1
//
//  Created by Sopana Thitipariwat on 11/26/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

import Foundation

class PinLocalityComposerDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, LocationTagCellDelegate {

    var locality = []
    var collectionView:UICollectionView!

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = self.locality.count
        collectionView.hidden = (count == 0)
        return count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return self.cellForCollectionView(collectionView, atIndexPath: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        var text:NSString? = self.locality[indexPath.item] as? NSString
        var size = CGSizeMake(100, 24)
        
        if text != nil {
            size = text!.sizeWithAttributes([NSFontAttributeName : UIFont.systemFontOfSize(13.0)])
            size.width += 30
            size.height = 24
        }
        
        return size
    }
    
    func cellForCollectionView(collectionView: UICollectionView, atIndexPath indexPath:NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as LocationTagCell
        cell.delegate = self
        cell.layer.borderColor = UIColor.hDarkGreyColor().CGColor
        cell.layer.borderWidth = 1.0
        cell.layer.cornerRadius = 2.0
        
        var label = cell.contentView.viewWithTag(100) as UILabel
        label.text = self.locality[indexPath.item] as? String
        //println(self.locality[indexPath.item])
        return cell
    }
    
    func locaionDidDeleteAt(cell: LocationTagCell) {
        var indexPath = self.collectionView.indexPathForCell(cell)!
        var ar:NSMutableArray = NSMutableArray(array: self.locality)
        
        ar.removeObjectAtIndex(indexPath.item)
        self.locality = ar
        self.collectionView.reloadData()
    }
}