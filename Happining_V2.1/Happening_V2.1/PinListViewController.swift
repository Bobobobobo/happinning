//
//  PinListViewController.swift
//  Happening_V2.1
//
//  Created by Kan Boonprakub on 8/12/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

import CoreLocation
import UIKit
import MobileCoreServices

class PinListViewController: BaseViewController ,
                            // Collection view
                            UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,
                            // Image Picker
                            UIImagePickerControllerDelegate, UINavigationControllerDelegate ,
                            // Table View
                            UITableViewDelegate, UITableViewDataSource,
                            // Text Input
                            UITextViewDelegate, UITextFieldDelegate,
                            // Custom
                            LoginViewDelegate, LocationDelegate, LocationTagCellDelegate {
                            
    @IBOutlet var pinsTableView : UITableView!
    @IBOutlet var sidebarButton : UIBarButtonItem!
    @IBOutlet weak var postViewConstraint: NSLayoutConstraint!
    
    // New pin
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var tagCollectionView: UICollectionView!
    @IBOutlet weak var placeTagField: UITextField!
    @IBOutlet weak var postImageButton: UIButton!
    @IBOutlet weak var postVideoButton: UIButton!
    @IBOutlet weak var postPinButton: UIButton!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var previewImageConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var noPinView: UIView!
    
    var refreshControl:UIRefreshControl!
    var request:PinRequest?
    
    let kCellIdentifier = "PinCell"
    let kPostViewSize:CGFloat = 142

    var pins:[Pin] = []
    var locality = []
    
    var api : APIController!
    
    var imageCache = [String : UIImage]()
    
    var hasMore = false
    var isShowPost = false
    
    var isLogin = false
    var isDragging = false
    var shouldHidePost = false
    var beginPoint = CGPointZero
    
    var selectedImage:UIImage?
    var selectedVideo:NSData?
    
    enum PostMedia : Int {
        case PostMediaNone = 0
        case PostMediaImage, PostMediaVideo
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        sidebarButton.target = self.revealViewController()
        sidebarButton.action = Selector("revealToggle:")

        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        self.api = APIController()
        
        self.refreshControl = UIRefreshControl(frame: CGRectMake(0, 0, self.pinsTableView.frame.size.width, 60))
        self.refreshControl.tintColor = UIColor.hRedColor()
        self.refreshControl.addTarget(self, action: "reloadPins:", forControlEvents: UIControlEvents.ValueChanged)
        self.pinsTableView.addSubview(self.refreshControl)
        
        // Logged in
        isLogin = User.isLogin()
        self.postViewConstraint.constant = 0;
        
        self.postTextView.scrollsToTop = false
        self.tagCollectionView.scrollsToTop = false
        
        self.adjustBorderForView(self.postTextView, withColor: UIColor.hRedColor())
        self.adjustBorderForView(self.postButton, withColor: UIColor.hgreyColor())
        self.adjustBorderForView(self.tagCollectionView.superview!, withColor: UIColor.hgreyColor())
    }
    
    func adjustBorderForView(view:UIView, withColor color:UIColor) {
        view.layer.borderWidth = 1.5
        view.layer.borderColor = color.CGColor
        view.layer.cornerRadius = 3.0
    }
    
    func onContentSizeChange(notification: NSNotification) {
        self.pinsTableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isLogin {
            self.performSegueWithIdentifier("signin", sender: self)
            isLogin = true
        } else {
            UserLocation.manager.startUpdatingLocation()
            UserLocation.manager.delegate = self
            
            NSNotificationCenter.defaultCenter().addObserver(self,
                selector: "onContentSizeChange:",
                name: UIContentSizeCategoryDidChangeNotification,
                object: nil)

            //testing
            //var latitude: Double = 13.7324541
            //var longitude: Double = 100.5309073
            //self.loadPinsAt(latitude, longitude: longitude)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func testTapped(sender: UIBarButtonItem!) {
        self.revealViewController().revealToggle(sender)
    }
    
    @IBAction func postNewPin(sender: AnyObject) {
        showNewPost(!isShowPost)
    }
    
    /**********************************
    *
    *   MARK: Location
    *
    ***********************************/
    
    func userLocationDidUpdateLocations(locations: [AnyObject]!) {
        var loc:CLLocation = locations[locations.count-1] as CLLocation
        var locValue: CLLocationCoordinate2D = loc.coordinate
        println("location = \(locValue.latitude) \(locValue.longitude)")
        
        var latitude: Double = locValue.latitude
        var longitude: Double = locValue.longitude
        var userId = User.currentUser.userID
        //self.api.getPins(latitude, longitude: longitude,distance: 100000, userId: userId, loadPins)
        self.loadPinsAt(latitude, longitude: longitude, page:1)
    }
    
    func userLocationDidUpdateGeoCoding(locality: [AnyObject]!) {
        if !self.placeTagField.isFirstResponder() && self.locality.count == 0 {
            self.locality = locality
            self.tagCollectionView.reloadData()
        }
    }
    
    /**********************************
    *
    *   MARK: New post
    *
    ***********************************/
    
    func showNewPost(show:Bool) {
        if show {
            self.postViewConstraint.constant = kPostViewSize
            
            if UserLocation.manager.subLocality.count > 0 {
                self.locality = UserLocation.manager.subLocality
                self.tagCollectionView.reloadData()
            }
        } else {
            self.postViewConstraint.constant = 0
            self.postTextView.resignFirstResponder()
            
            self.postImageButton.selected = false
            self.previewImageView.image = nil
        }
        
        self.view.userInteractionEnabled = false
        self.pinsTableView.scrollEnabled = false
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: {(conplete) -> Void in
            self.view.userInteractionEnabled = true
            self.pinsTableView.scrollEnabled = true
            self.pinsTableView.contentOffset = CGPointMake(0, -self.pinsTableView.contentInset.top)
        })
        
        self.isShowPost = show
    }
    
    @IBAction func addNewPin(sender: AnyObject) {
        if strlen(self.postTextView.text) == 0 {
            self.postTextView.becomeFirstResponder()
            return
        }
        
        if self.locality.count == 0 {
            self.placeTagField.becomeFirstResponder()
            return
        }
        
        if self.request != nil {
            var subLocal = self.locality.firstObject as String
            var locality = (UserLocation.manager.locality as NSArray).componentsJoinedByString(",")
            
            var postPinRequest = PostPinRequest()
            postPinRequest.latitude = self.request!.latitude
            postPinRequest.longitude = self.request!.longitude
            postPinRequest.pinLocality = locality
            postPinRequest.pinSubLocality = subLocal
            postPinRequest.userID = User.currentUser.userID!
            postPinRequest.pinText = self.postTextView.text
            
            if self.previewImageView.image != nil {
                postPinRequest.pinImage = self.previewImageView.image
            }
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            self.postButton.enabled = false
            
            postPinRequest.upload({ (result) -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.postButton.enabled = true

                var response:PinResponse = result as PinResponse
                if response.pins.count > 0 {
                    self.showNewPost(false)
                    self.postTextView.text = ""
                    self.pins = response.pins + self.pins
                    self.pinsTableView.reloadData()
                }
            })
        }
    }
    
    @IBAction func addNewImage(sender: AnyObject) {
        self.postImageButton.selected = !self.postImageButton.selected
        
        if self.postImageButton.selected {
            showImagePickerFor(PostMedia.PostMediaImage)
        } else {
            self.postViewConstraint.constant = kPostViewSize
            self.view.layoutIfNeeded()
            self.previewImageView.image = nil
        }
    }
    
    @IBAction func addNewVideo(sender: AnyObject) {
        showImagePickerFor(PostMedia.PostMediaVideo)
    }
    
    // MARK: Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Return number of row for pins
        return self.pins.count;
    }
    
    func configureCellAtIndexPaht(indexPath: NSIndexPath) -> UITableViewCell {
        //Process result cell in the tableView
        var cell = self.pinsTableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as PinTableViewCell
        
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
        return self.configureCellAtIndexPaht(indexPath)
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 360
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var cell = self.configureCellAtIndexPaht(indexPath)
        return self.calculateHeightForConfiguredSizingCell(cell)
        //return UITableViewAutomaticDimension
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if scrollView == self.pinsTableView {
            isDragging = true
            beginPoint = scrollView.contentOffset
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == self.pinsTableView {
            isDragging = false
            endingScroll()
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView == self.pinsTableView {
            isDragging = false
            endingScroll()
        }
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        if scrollView == self.pinsTableView {
            isDragging = false
            endingScroll()
        }
    }
    
    func endingScroll() {
        if shouldHidePost {
            self.postViewConstraint.constant = 0
            showNewPost(false)
            shouldHidePost = false
        } else if !isShowPost {
            self.postViewConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func scrollViewDidScroll(aScrollView: UIScrollView) {
        if aScrollView == self.pinsTableView {
            var offset:CGPoint = aScrollView.contentOffset
            var bounds:CGRect = aScrollView.bounds
            var size:CGSize = aScrollView.contentSize
            var inset:UIEdgeInsets = aScrollView.contentInset
            var y:CGFloat = offset.y + bounds.size.height - inset.bottom
            var h:CGFloat = size.height
            var reload_distance:CGFloat = 10
            
            if((y > (h + reload_distance)) && hasMore) {
                if  self.request != nil {
                    self.loadPinsAt(self.request!.latitude, longitude: self.request!.longitude, page: request!.page+1)
                }
            } else if beginPoint.y < offset.y {
                if isShowPost {
                    shouldHidePost = true
                    self.postViewConstraint.constant -= (offset.y - beginPoint.y)
                    self.view.layoutIfNeeded()
                    aScrollView.contentOffset = CGPointZero
                }
            }
        }
    }
    
    /**********************************
    *
    *   MARK: Load Pin
    *
    ***********************************/

    func loadPinsAt(latitude:Double, longitude:Double, page:Int) {
        if self.request != nil {
            if self.request!.task!.state == .Running {
                return;
            }
        }

        var userId = User.currentUser.userID
        //self.api.getPins(latitude, longitude: longitude,distance: 100000, userId: userId, loadPins)
        var request = PinRequest()
        request.latitude = latitude
        request.longitude = longitude
        request.userID = userId!
        request.distance = 100000
        request.page = page
        self.request = request
        self.request!.request(handleResponse)
    }
    
    func reloadPins(sender:AnyObject?) {
//        if  self.request != nil {
//            self.request!.page = 1;
//            self.request!.request(handleResponse)
//        }
        UserLocation.manager.startUpdatingLocation()
    }
    
    func handleResponse(result:BaseResponse) {
        var response = result as PinResponse

        if self.request != nil {
            if response.pins.count > 0 {
                if self.request!.page == 1 {
                    self.pins = response.pins
                    self.pinsTableView.contentOffset = CGPointMake(0, -self.pinsTableView.contentInset.top);
                } else {
                    self.pins += response.pins
                }
                
                //println("pins \(self.pins.count)")
                
                hasMore = !(response.pins.count < 20)
            }
            
            self.noPinView.hidden = (self.pins.count > 0)
        }
        
        self.pinsTableView.reloadData()
        self.refreshControl.endRefreshing()
    }

    /**********************************
    *
    *   MARK: Navigation
    *
    ***********************************/
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier != nil) {
            var segueID = segue.identifier!
            if (segueID == "signin") {
                var navigationController:UINavigationController = segue.destinationViewController as UINavigationController
                var loginController:LoginViewController = navigationController.viewControllers[0] as LoginViewController
                loginController.delegate = self
            }
        }
    }
    
    /**********************************
    *
    *   MARK: Login Delegate
    *
    ***********************************/

    func loginViewDidFinishWithUser(user: User?) {
        if user != nil {
            println("Finish login with \(user!.userName)")
        } else {
            println("Login Error")
        }
    }
    
    /**********************************
    *
    *   MARK: Tagging view collection
    *
    ***********************************/
    
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
        var indexPath = self.tagCollectionView.indexPathForCell(cell)!
        var ar:NSMutableArray = NSMutableArray(array: self.locality)
        
        ar.removeObjectAtIndex(indexPath.item)
        self.locality = ar
        self.tagCollectionView.reloadData()
    }
    
    @IBAction func clearAllLocation(sender: AnyObject) {
        self.locality = []
        self.tagCollectionView.reloadData()
    }
    
    /**********************************
    *
    *   MARK: Text field
    *
    ***********************************/
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if strlen(textField.text) > 0 {
            self.locality = [textField.text]
            self.tagCollectionView.reloadData()
            textField.text = ""
        }
    }
    
    /**********************************
    *
    *   MARK: Image Picker
    *
    ***********************************/
    
    func showImagePickerFor(mediaType:PostMedia) {
        var picker = UIImagePickerController()
        picker.mediaTypes = [kUTTypeImage]
        picker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            picker.sourceType = .Camera
        }
        
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.postViewConstraint.constant = kPostViewSize + CGRectGetWidth(self.view.frame)
        self.view.layoutIfNeeded()
        self.previewImageView.image = image
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

