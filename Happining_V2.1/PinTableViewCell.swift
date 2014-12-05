//
//  PinTableViewCell.swift
//  Happining_V2.1
//
//  Created by Kan Boonprakub on 9/17/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

import UIKit
import MediaPlayer

protocol PinTableViewCellDelegate : NSObjectProtocol {
    func pinCellLikeAtCell(cell:PinTableViewCell!)
    func pinCellCommentAtCell(cell:PinTableViewCell!)
}

class PinTableViewCell: UITableViewCell {

    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var pinTitle: UILabel!
    @IBOutlet var userName: UILabel!
    @IBOutlet var pintypeImage: UIImageView!
    @IBOutlet var pinImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var commentButton: UIButton!
    @IBOutlet var likeView: UIView!
    @IBOutlet var likeLabel: UILabel!
    @IBOutlet var commentView: UIView!
    @IBOutlet var commentLabel: UILabel!
    
    @IBOutlet var imageHeight:NSLayoutConstraint?

    @IBOutlet var locaionLabel: UILabel?
    @IBOutlet var timeLabel: UILabel?
    @IBOutlet var distanceLabel: UILabel?
    
    let mediaPlayer = MPMoviePlayerController()

    var delegate:PinTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.mediaPlayer.shouldAutoplay = false
        self.mediaPlayer.controlStyle = .None
        self.mediaPlayer.movieSourceType = .Streaming
        self.mediaPlayer.view.frame = self.pinImage!.bounds
        self.pinImage!.addSubview(self.mediaPlayer.view)
        self.mediaPlayer.view.backgroundColor = UIColor.clearColor()
        self.mediaPlayer.view.userInteractionEnabled = false
        self.mediaPlayer.view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        self.mediaPlayer.view.hidden = true

        var tapGesture = UITapGestureRecognizer(target: self, action: Selector("playPreviewVideo:"))
        self.pinImage!.userInteractionEnabled = true
        self.pinImage!.addGestureRecognizer(tapGesture)
    }
    
    func playPreviewVideo(sender: AnyObject) {
        var tapGesture = sender as UITapGestureRecognizer
        if self.mediaPlayer.contentURL != nil {
            if self.mediaPlayer.playbackState == .Playing {
                self.mediaPlayer.view.alpha = 0.0
                self.mediaPlayer.stop()
            } else {
                self.mediaPlayer.view.alpha = 1.0
                self.mediaPlayer.play()
            }
        }
    }
    
    @IBAction func likeAction(sender: AnyObject) {
        if self.delegate != nil && self.delegate!.respondsToSelector(Selector("pinCellLikeAtCell:")) {
            self.delegate!.pinCellLikeAtCell(self)
        }
    }
    
    @IBAction func commentAction(sender: AnyObject) {
        if self.delegate != nil && self.delegate!.respondsToSelector(Selector("pinCellCommentAtCell:")) {
            self.delegate!.pinCellCommentAtCell(self)
        }
    }
}
