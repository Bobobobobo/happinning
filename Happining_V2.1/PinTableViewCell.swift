//
//  PinTableViewCell.swift
//  Happining_V2.1
//
//  Created by Kan Boonprakub on 9/17/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

import UIKit
import MediaPlayer

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

    @IBOutlet var locaionLabel: UILabel?
    @IBOutlet var timeLabel: UILabel?
    @IBOutlet var distanceLabel: UILabel?
    
    let mediaPlayer = MPMoviePlayerController()

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
        if !self.mediaPlayer.view.hidden && tapGesture.state == .Ended {
            if self.mediaPlayer.playbackState == .Playing {
                self.mediaPlayer.stop()
            } else {
                self.mediaPlayer.play()
            }
        }
    }
}
