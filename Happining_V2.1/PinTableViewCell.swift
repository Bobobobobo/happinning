//
//  PinTableViewCell.swift
//  Happining_V2.1
//
//  Created by Kan Boonprakub on 9/17/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

import UIKit

class PinTableViewCell: UITableViewCell {

    @IBOutlet var profileImage: UIImageView?
    @IBOutlet var pinTitle: UILabel?
    @IBOutlet var userName: UILabel?
    @IBOutlet var pintypeImage: UIImageView?
    @IBOutlet var pinImage: UIImageView?
    @IBOutlet var likeButton: UIButton?
    @IBOutlet var commentButton: UIButton?
    @IBOutlet var likeView: UIView?
    @IBOutlet var commentView: UIView?
    
    @IBOutlet var imageHeight:NSLayoutConstraint?
}
