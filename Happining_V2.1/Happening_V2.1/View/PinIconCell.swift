//
//  PinIconCell.swift
//  Happining_V2.1
//
//  Created by Sopana Thitipariwat on 11/26/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

import UIKit

class PinIconCell: UICollectionViewCell {

    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!

    override var selected: Bool {
        didSet {
            self.contentView.backgroundColor = (selected ? UIColor.hgreyColor() : UIColor.clearColor())
        }
    }
}