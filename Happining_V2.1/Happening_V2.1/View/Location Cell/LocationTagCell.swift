//
//  LocationTagCell.swift
//  Happining_V2.1
//
//  Created by Sopana Thitipariwat on 11/26/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

import UIKit

protocol LocationTagCellDelegate : NSObjectProtocol {
    func locaionDidDeleteAt(cell: LocationTagCell)
}

class LocationTagCell: UICollectionViewCell {

    var delegate: LocationTagCellDelegate?

    @IBAction func removeLocation(sender: AnyObject) {
        if self.delegate != nil {
            var delegate = self.delegate!
            if delegate.respondsToSelector(Selector("locaionDidDeleteAt:")) {
                delegate.locaionDidDeleteAt(self)
            }
        }
    }
}
