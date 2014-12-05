//
//  PinDetailViewController.swift
//  Happening_V2.1
//
//  Created by Kan Boonprakub on 8/12/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

import UIKit
import MediaPlayer

class PinDetailViewController: BaseViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var pinView: UIView!
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

    @IBOutlet var imageHeight:NSLayoutConstraint!
    
    @IBOutlet var locaionLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    
    @IBOutlet var commentTextView: UITextView!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet var tableView: UITableView!
    
    var pin:Pin?
    var comments:[Comment] = []
    var hasMore = false

    let request = PinDetailRequest()
    let commentRequest = CommentRequest()
    let mediaPlayer = MPMoviePlayerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
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
        self.tableView.keyboardDismissMode = .OnDrag
        
        self.commentTextView.layer.cornerRadius = 3.0
        self.commentTextView.layer.borderWidth = 1.5
        self.commentTextView.layer.borderColor = UIColor.hRedColor().CGColor
        
        self.updatePin()

        if self.pin != nil {
            var pin = self.pin!
            
            self.request.pinID = pin.pinId
            self.request.userID = User.currentUser.userID!
            self.request.request({ (result) -> Void in
                var response:PinResponse = result as PinResponse
                if response.pins.count > 0 {
                    var p = response.pins[0]
                    pin.isLike = p.isLike
                    pin.likesNum = p.likesNum
                    self.updatePin()
                }
            })
            
            self.commentRequest.pinID = pin.pinId
            self.commentRequest.page = 1
            self.commentRequest.request(handleResponse)
        }
    }

    func updatePin() {
        if self.pin != nil {
            var pin = self.pin!
            self.pinTitle?.text = pin.text
            
            if pin.pinName != nil {
                self.pintypeImage?.image = UIImage(named: "\(pin.pinName!).png")
            }
            
            var locality = ""
            if strlen(pin.location.subLocality) > 0 {
                locality = pin.location.subLocality
            }
            
            self.locaionLabel?.text = locality
            self.timeLabel?.text = pin.uploadDate.formattedAsTimeAgo()
            
            if self.mediaPlayer.playbackState == .Playing {
                self.mediaPlayer.stop()
            }
            
            self.mediaPlayer.view.hidden = true
            
            if pin.distance >= 0.1 {
                self.distanceLabel?.text = NSString(format: "%.1f km", pin.distance)
            } else {
                self.distanceLabel?.text = NSString(format: "%.1f m", pin.distance*1000)
            }
            
            var baseURL = BASE_URL
            if pin.thumbURL == nil || strlen(pin.thumbURL!) == 0 {
                self.imageHeight!.constant = 0.0
                self.pinImage?.hidden = true
            } else {
                self.imageHeight!.constant = 200.0
                self.pinImage?.hidden = false
                
                var urlString = "\(baseURL)\(pin.thumbURL!)"
                
                if pin.imageURL != nil && strlen(pin.imageURL!) > 0 {
                    urlString = "\(baseURL)\(pin.imageURL!)"
                    self.pinImage?.contentMode = .ScaleAspectFill
                } else if pin.videoURL != nil && strlen(pin.videoURL!) > 0 {
                    self.mediaPlayer.contentURL = NSURL(string: "\(baseURL)\(pin.videoURL!)")
                    self.mediaPlayer.view.hidden = false
                    self.mediaPlayer.view.alpha = 0.0
                    self.mediaPlayer.prepareToPlay()
                    self.pinImage?.contentMode = .ScaleAspectFit
                }
                
                self.pinImage?.sd_setImageWithURL(NSURL(string: urlString))
            }
            
            self.profileImage?.sd_setImageWithURL(NSURL(string: pin.userImageURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!))
            self.userName?.text = pin.userName
            
            updateLike()
            
            if pin.commentsNum > 0 {
                self.commentLabel.text = NSString(format: "%d Comment%@", pin.commentsNum, (pin.commentsNum > 1 ? "s" : ""))
            } else {
                self.commentLabel.text = "Comment"
            }
            
            var attrText = NSAttributedString(string: self.pinTitle!.text!, attributes: [NSFontAttributeName : self.pinTitle!.font])
            
            //println(attrText)
            
            var rect:CGRect = attrText.boundingRectWithSize(CGSizeMake(CGRectGetWidth(self.pinTitle!.frame), CGFloat.max), options: .UsesLineFragmentOrigin, context: nil)
            
            //println(rect)
            
            var size = rect.size
            var frame = self.pinView!.frame
            frame.size.height = 158
            frame.size.height += self.imageHeight!.constant
            frame.size.height += size.height - 17
            self.pinView!.frame = frame
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillShowNotification, object: nil, queue: nil) { (note) -> Void in
            var notification = note as NSNotification
            
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                
                var durationVal = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSValue
                var duration = durationVal as NSTimeInterval
                self.bottomConstraint!.constant = keyboardSize.size.height
                
                UIView.animateWithDuration(duration,
                    delay:0,
                    options:UIViewAnimationOptions.allZeros ,
                    animations: { () -> Void in
                        self.view.layoutIfNeeded()
                    }, completion: { (complete) -> Void in

                })
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillHideNotification, object: nil, queue: nil) { (note) -> Void in
            self.bottomConstraint!.constant = 0
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.view.layoutIfNeeded()
            }, completion: { (complete) -> Void in

            })
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func handleResponse(result:BaseResponse) {
        var response = result as CommentResponse

        if response.comments.count > 0 {
            if self.commentRequest.page == 1 {
                self.comments = response.comments
            } else {
                self.comments += response.comments
            }
            
            hasMore = (self.pin!.commentsNum > self.comments.count)
            
            if response.commentsNum != nil {
                self.pin!.commentsNum = response.commentsNum!
            }
        }
        
        self.tableView.reloadData()
    }
    
    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    func updateLike() {
        var pin = self.pin!

        if pin.likesNum > 0 {
            self.likeLabel.text = NSString(format: "%d Like%@", pin.likesNum, (pin.likesNum > 1 ? "s" : ""))
        } else {
            self.likeLabel.text = "Like"
        }
        
        self.likeButton?.selected = pin.isLike
    }
    
    @IBAction func likeAction(sender: AnyObject) {
        var pin = self.pin!
        
        pin.isLike = !pin.isLike
        pin.likesNum += (pin.isLike ? 1 : -1)
        
        updateLike()
        
        var request = PinLikeRequest()
        request.pinID = pin.pinId
        request.isLike = pin.isLike
        request.userID = User.currentUser.userID!
        request.request { (result) -> Void in
            if result.error == nil {
                pin.isLike = !pin.isLike
                pin.likesNum += (pin.isLike ? 1 : -1)
                
                self.updateLike()
            }
        }
    }
    
    @IBAction func commentAction(sender: AnyObject) {
        var request = PostCommentRequest()
        request.pinID = self.pin!.pinId
        request.text = self.commentTextView.text
        request.userID = User.currentUser.userID!
        request.request { (result) -> Void in
            if result.error == nil {
                var comment:Comment = Comment()
                comment.text = request.text
                comment.userImage = User.currentUser.userImage
                comment.userID = User.currentUser.userID
                comment.userName = User.currentUser.userName
                comment.date = NSDate()
                self.comments.append(comment)
                
                self.pin?.commentsNum++
                
                self.commentLabel.text = NSString(format: "%d Comment%@", self.pin!.commentsNum, (self.pin!.commentsNum > 1 ? "s" : ""))

                self.commentTextView.text = ""
                self.commentTextView.resignFirstResponder()
                self.tableView.reloadData()
            }
        }
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
    
    /**********************************
    *
    *   MARK: Table view
    *
    ***********************************/
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->
        UITableViewCell {
        return self.configureCellFor(tableView, atIndexPaht: indexPath)
    }
    
    func configureCellFor(tableView:UITableView, atIndexPaht indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell") as CommentCell
        var comment = self.comments[indexPath.row]
        
        if comment.userImage != nil {
            cell.profileImage.sd_setImageWithURL(NSURL(string: comment.userImage!.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!))
        }
        
        cell.userLabel.text = comment.userName
        cell.commentLabel.text = comment.text
        cell.dateLabel.text = comment.date?.formattedAsTimeAgo()

        return cell
    }

    func calculateHeightForConfiguredSizingCell(cell:UITableViewCell) -> CGFloat {
        var commentCell = cell as CommentCell
        var attrText = NSAttributedString(string: commentCell.commentLabel.text!, attributes: [NSFontAttributeName : commentCell.commentLabel.font])

        var rect:CGRect = attrText.boundingRectWithSize(CGSizeMake(CGRectGetWidth(commentCell.commentLabel.frame), CGFloat.max), options: .UsesLineFragmentOrigin, context: nil)

        return 63 + CGRectGetHeight(rect)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var comment = self.comments[indexPath.row]
        
        if comment.height > 0 {
            return comment.height
        }
        
        var cell = self.configureCellFor(tableView, atIndexPaht: indexPath)
        comment.height = self.calculateHeightForConfiguredSizingCell(cell)
        return comment.height
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
            if self.commentRequest.task?.state == NSURLSessionTaskState.Completed {
                self.commentRequest.page = 1
                self.commentRequest.request(handleResponse)
            }
        }
    }
    
}
